import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Минимальное извлечение текста из PDF (ADR-0012): FlateDecode-потоки,
/// текстовые операторы Tj/TJ/' и ToUnicode CMap для кириллицы. Этого
/// достаточно для текстовых выписок (Сбербанк и большинство банков);
/// сканы и экзотические кодировки не поддерживаются.
String extractPdfText(Uint8List bytes) {
  final data = latin1.decode(bytes, allowInvalid: true);
  final cmap = <int, String>{};
  final contents = <String>[];

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
    if (text.contains('beginbfchar') || text.contains('beginbfrange')) {
      _parseCmap(text, cmap);
    } else if (text.contains('BT') &&
        (text.contains('Tj') || text.contains('TJ'))) {
      contents.add(text);
    }
  }

  final buffer = StringBuffer();
  for (final content in contents) {
    _extractFromContent(content, cmap, buffer);
  }
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

/// Текстовые операторы контент-потока: строки Tj/TJ/', переводы
/// строк на Td/TD/T*.
void _extractFromContent(
    String content, Map<int, String> cmap, StringBuffer out) {
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
            _ => next.codeUnitAt(0),
          });
        }
      } else {
        bytes.add(c.codeUnitAt(0));
      }
    }
    final sb = StringBuffer();
    for (final code in bytes) {
      sb.write(cmap[code] ?? String.fromCharCode(code));
    }
    return sb.toString();
  }

  final token = RegExp(
    r'\((?:[^()\\]|\\.)*\)|<[0-9A-Fa-f\s]+>|\[|\]|[A-Za-z\*][A-Za-z\*]?|[-+]?[\d.]+',
    dotAll: true,
  );
  final pendingStrings = <String>[];
  for (final match in token.allMatches(content)) {
    final t = match.group(0)!;
    if (t.startsWith('(')) {
      pendingStrings.add(decodeLiteral(t.substring(1, t.length - 1)));
    } else if (t.startsWith('<')) {
      pendingStrings
          .add(decodeHex(t.replaceAll(RegExp(r'[<>\s]'), '')));
    } else if (t == 'Tj' || t == 'TJ' || t == "'") {
      out.writeAll(pendingStrings);
      pendingStrings.clear();
    } else if (t == 'Td' || t == 'TD' || t == 'T*') {
      if (out.isNotEmpty) out.write('\n');
      pendingStrings.clear();
    } else if (t == 'BT' || t == 'ET') {
      pendingStrings.clear();
    }
  }
}
