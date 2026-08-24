import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Минимальное извлечение текста из PDF (ADR-0012): FlateDecode-потоки,
/// текстовые операторы Tj/TJ/' и ToUnicode CMap для кириллицы.
///
/// В настоящих банковских PDF (СберБанк) несколько шрифтов, у каждого —
/// своя таблица ToUnicode, поэтому перекодировка ведётся по активному
/// шрифту (оператор Tf): объекты → шрифты страницы → CMap каждого.
/// Объекты внутри /ObjStm тоже разбираются. Сканы не поддерживаются.
String extractPdfText(Uint8List bytes) {
  final data = latin1.decode(bytes, allowInvalid: true);

  // --- Заголовки объектов «N 0 obj»: по позиции потока находим хозяина.
  final headers = <({int num, int pos, int end})>[];
  for (final m in RegExp(r'(\d+)\s+0\s+obj\b').allMatches(data)) {
    headers.add((num: int.parse(m.group(1)!), pos: m.start, end: m.end));
  }
  int? ownerOf(int pos) {
    ({int num, int pos, int end})? best;
    for (final h in headers) {
      if (h.pos < pos && (best == null || h.pos > best.pos)) best = h;
    }
    return best?.num;
  }

  // Текст словаря объекта — от заголовка до stream/endobj.
  final dicts = <int, String>{};
  for (final h in headers) {
    var end = data.length;
    for (final stop in ['stream', 'endobj']) {
      final idx = data.indexOf(stop, h.end);
      if (idx != -1 && idx < end) end = idx;
    }
    dicts[h.num] = data.substring(h.end, end);
  }

  // --- Потоки: раскодировать, привязать к объектам.
  final streams = <int, String>{};
  var searchFrom = 0;
  while (true) {
    final streamStart = data.indexOf('stream', searchFrom);
    if (streamStart == -1) break;
    var contentStart = streamStart + 'stream'.length;
    if (contentStart < data.length && data[contentStart] == '\r') {
      contentStart++;
    }
    if (contentStart < data.length && data[contentStart] == '\n') {
      contentStart++;
    }
    final streamEnd = data.indexOf('endstream', contentStart);
    if (streamEnd == -1) break;
    searchFrom = streamEnd + 'endstream'.length;

    final dictStart = data.lastIndexOf('<<', streamStart);
    final dict =
        dictStart == -1 ? '' : data.substring(dictStart, streamStart);

    var raw = bytes.sublist(contentStart, streamEnd);
    // Хвостовые EOL перед endstream не входят в данные потока.
    while (raw.isNotEmpty && (raw.last == 0x0A || raw.last == 0x0D)) {
      raw = raw.sublist(0, raw.length - 1);
    }
    List<int> decoded = raw;
    if (dict.contains('/FlateDecode')) {
      try {
        decoded = const ZLibDecoder().decodeBytes(raw);
      } catch (_) {
        continue;
      }
    }
    final text = latin1.decode(decoded, allowInvalid: true);
    // Потоки вне объектов (упрощённые PDF) получают синтетический
    // ключ — работают через общий запасной CMap.
    final owner = ownerOf(streamStart) ?? -(streams.length + 1);
    streams[owner] = text;

    // Объекты, упакованные в /ObjStm: словари шрифтов и страниц.
    if (dict.contains('/ObjStm')) {
      final first =
          int.tryParse(RegExp(r'/First\s+(\d+)').firstMatch(dict)?.group(1) ??
              '');
      if (first != null && first <= text.length) {
        final pairs = RegExp(r'\d+')
            .allMatches(text.substring(0, first))
            .map((m) => int.parse(m.group(0)!))
            .toList();
        for (var i = 0; i + 1 < pairs.length; i += 2) {
          final embeddedNum = pairs[i];
          final start = first + pairs[i + 1];
          final end = i + 3 < pairs.length
              ? first + pairs[i + 3]
              : text.length;
          if (start <= text.length && start < end) {
            dicts[embeddedNum] = text.substring(
                start, end.clamp(start, text.length));
          }
        }
      }
    }
  }

  // --- CMap каждого ToUnicode-потока по номеру объекта.
  final cmapByObj = <int, Map<int, String>>{};
  final merged = <int, String>{}; // общий запасной вариант
  streams.forEach((objNum, text) {
    if (text.contains('beginbfchar') || text.contains('beginbfrange')) {
      final cmap = <int, String>{};
      _parseCmap(text, cmap);
      cmapByObj[objNum] = cmap;
      cmap.forEach((k, v) => merged.putIfAbsent(k, () => v));
    }
  });

  // --- Шрифт → его CMap (по ссылке /ToUnicode N 0 R).
  final fontCmap = <int, Map<int, String>>{};
  dicts.forEach((objNum, dict) {
    if (!dict.contains('/Font')) return;
    final ref = RegExp(r'/ToUnicode\s+(\d+)\s+0\s+R').firstMatch(dict);
    if (ref == null) return;
    final cmap = cmapByObj[int.parse(ref.group(1)!)];
    if (cmap != null) fontCmap[objNum] = cmap;
  });

  // --- Страницы: имена шрифтов ресурсов + контент-потоки.
  final buffer = StringBuffer();
  final usedContents = <int>{};
  dicts.forEach((objNum, dict) {
    if (!RegExp(r'/Type\s*/Page\b').hasMatch(dict)) return;

    var resources = dict;
    final resRef = RegExp(r'/Resources\s+(\d+)\s+0\s+R').firstMatch(dict);
    if (resRef != null) {
      resources = dicts[int.parse(resRef.group(1)!)] ?? '';
    }
    final fontsByName = <String, Map<int, String>>{};
    for (final m in RegExp(r'/(\w+)\s+(\d+)\s+0\s+R')
        .allMatches(resources)) {
      final cmap = fontCmap[int.parse(m.group(2)!)];
      if (cmap != null) fontsByName[m.group(1)!] = cmap;
    }

    for (final m
        in RegExp(r'/Contents\s+((?:\[[^\]]*\])|(?:\d+\s+0\s+R))')
            .allMatches(dict)) {
      for (final ref in RegExp(r'(\d+)\s+0\s+R').allMatches(m.group(1)!)) {
        final contentNum = int.parse(ref.group(1)!);
        final content = streams[contentNum];
        if (content == null || !usedContents.add(contentNum)) continue;
        _extractFromContent(content, fontsByName, merged, buffer);
      }
    }
  });
  if (buffer.isNotEmpty) return buffer.toString();

  // Запасной путь: страницы не разобрались — как раньше, все текстовые
  // потоки с общим CMap.
  streams.forEach((objNum, text) {
    if (text.contains('BT') &&
        (text.contains('Tj') || text.contains('TJ'))) {
      _extractFromContent(text, const {}, merged, buffer);
    }
  });
  return buffer.toString();
}

/// bfchar/bfrange из ToUnicode CMap: код глифа → текст (UTF-16BE hex).
void _parseCmap(String text, Map<int, String> cmap) {
  String decodeUtf16Hex(String hex) {
    final units = <int>[];
    for (var i = 0; i + 4 <= hex.length; i += 4) {
      units.add(int.parse(hex.substring(i, i + 4), radix: 16));
    }
    return String.fromCharCodes(units);
  }

  for (final section in RegExp(r'beginbfchar(.*?)endbfchar', dotAll: true)
      .allMatches(text)) {
    for (final pair in RegExp(r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')
        .allMatches(section.group(1)!)) {
      final code = int.parse(pair.group(1)!, radix: 16);
      cmap.putIfAbsent(code, () => decodeUtf16Hex(pair.group(2)!));
    }
  }
  for (final section in RegExp(r'beginbfrange(.*?)endbfrange', dotAll: true)
      .allMatches(text)) {
    for (final range in RegExp(
            r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')
        .allMatches(section.group(1)!)) {
      final lo = int.parse(range.group(1)!, radix: 16);
      final hi = int.parse(range.group(2)!, radix: 16);
      final dst = int.parse(range.group(3)!, radix: 16);
      for (var code = lo; code <= hi && code - lo < 65536; code++) {
        cmap.putIfAbsent(
            code, () => String.fromCharCode(dst + (code - lo)));
      }
    }
  }
}

/// Текстовые операторы контент-потока: строки Tj/TJ/', переводы строк
/// на Td/TD/T*. Активный CMap переключается оператором Tf по имени
/// шрифта из ресурсов страницы; [fallback] — общий CMap, если шрифт
/// не распознан.
void _extractFromContent(
  String content,
  Map<String, Map<int, String>> fontsByName,
  Map<int, String> fallback,
  StringBuffer out,
) {
  var cmap = fallback;

  String decodeHex(String hex) {
    // Сначала двухбайтовые коды (CID-шрифты), затем однобайтовые.
    if (cmap.isNotEmpty && hex.length % 4 == 0) {
      final sb = StringBuffer();
      var allKnown = true;
      for (var i = 0; i + 4 <= hex.length; i += 4) {
        final code = int.parse(hex.substring(i, i + 4), radix: 16);
        final mapped = cmap[code];
        if (mapped == null) {
          allKnown = false;
          break;
        }
        sb.write(mapped);
      }
      if (allKnown) return sb.toString();
    }
    final sb = StringBuffer();
    for (var i = 0; i + 2 <= hex.length; i += 2) {
      final code = int.parse(hex.substring(i, i + 2), radix: 16);
      sb.write(cmap[code] ?? String.fromCharCode(code));
    }
    return sb.toString();
  }

  String decodeLiteral(String s) {
    final bytes = <int>[];
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == r'\' && i + 1 < s.length) {
        i++;
        final next = s[i];
        if (RegExp(r'\d').hasMatch(next)) {
          var oct = next;
          while (oct.length < 3 &&
              i + 1 < s.length &&
              RegExp(r'\d').hasMatch(s[i + 1])) {
            i++;
            oct += s[i];
          }
          bytes.add(int.parse(oct, radix: 8) & 0xFF);
        } else {
          bytes.add(switch (next) {
            'n' => 0x0A,
            'r' => 0x0D,
            't' => 0x09,
            'b' => 0x08,
            'f' => 0x0C,
            _ => next.codeUnitAt(0),
          });
        }
      } else {
        bytes.add(c.codeUnitAt(0));
      }
    }
    // CID-шрифт: строка — последовательность двухбайтовых кодов.
    if (bytes.length.isEven && cmap.keys.any((k) => k > 0xFF)) {
      final sb = StringBuffer();
      var allKnown = true;
      for (var i = 0; i + 2 <= bytes.length; i += 2) {
        final mapped = cmap[(bytes[i] << 8) | bytes[i + 1]];
        if (mapped == null) {
          allKnown = false;
          break;
        }
        sb.write(mapped);
      }
      if (allKnown) return sb.toString();
    }
    final sb = StringBuffer();
    for (final code in bytes) {
      sb.write(cmap[code] ?? String.fromCharCode(code));
    }
    return sb.toString();
  }

  // Литеральные строки могут содержать сбалансированные скобки без
  // экранирования — «(МСК)», «(Ozon)»; поддерживаем один уровень.
  final token = RegExp(
    r'\((?:[^()\\]|\\.|\((?:[^()\\]|\\.)*\))*\)|<[0-9A-Fa-f\s]+>|/[\w.#]+|\[|\]|[A-Za-z\*][A-Za-z\*]?|[-+]?[\d.]+',
    dotAll: true,
  );
  final pendingStrings = <String>[];
  String? lastName;
  for (final match in token.allMatches(content)) {
    final t = match.group(0)!;
    if (t.startsWith('(')) {
      pendingStrings.add(decodeLiteral(t.substring(1, t.length - 1)));
    } else if (t.startsWith('<')) {
      pendingStrings
          .add(decodeHex(t.replaceAll(RegExp(r'[<>\s]'), '')));
    } else if (t.startsWith('/')) {
      lastName = t.substring(1);
    } else if (t == 'Tf') {
      cmap = fontsByName[lastName] ?? fallback;
      pendingStrings.clear();
    } else if (t == 'Tj' || t == 'TJ' || t == "'") {
      out.writeAll(pendingStrings);
      pendingStrings.clear();
    } else if (t == 'Td' || t == 'TD' || t == 'T*' || t == 'Tm') {
      // Tm — новая текстовая матрица: генераторы (СберБанк) позицио-
      // нируют каждый фрагмент ею, а не Td.
      if (out.isNotEmpty) out.write('\n');
      pendingStrings.clear();
    } else if (t == 'BT' || t == 'ET') {
      pendingStrings.clear();
    }
  }
}
