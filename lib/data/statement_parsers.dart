import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'pdf_text.dart';

/// Форматы банковских выписок (ADR-0012). Все парсеры приводят файл
/// к таблице строк, которая дальше идёт в общий пайплайн импорта
/// (маппинг колонок → предпросмотр → дедупликация).
enum StatementFormat { csv, ofx, xlsx, pdf }

/// Определяет формат по содержимому и имени файла.
StatementFormat detectFormat(String fileName, Uint8List bytes) {
  final lower = fileName.toLowerCase();
  // XLSX — это zip: сигнатура PK\x03\x04.
  if (bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04) {
    return StatementFormat.xlsx;
  }
  final head = latin1
      .decode(bytes.take(2048).toList(), allowInvalid: true)
      .toUpperCase();
  if (head.startsWith('%PDF')) return StatementFormat.pdf;
  if (lower.endsWith('.ofx') ||
      head.contains('<OFX') ||
      head.contains('OFXHEADER')) {
    return StatementFormat.ofx;
  }
  return StatementFormat.csv;
}

/// OFX (Open Financial Exchange, SGML/XML): блоки STMTTRN с датой,
/// суммой и описанием превращаются в таблицу с заголовком, которую
/// узнаёт автоматический маппинг колонок.
List<List<String>> parseOfx(String content) {
  String? tagValue(String block, String tag) {
    final match = RegExp('<$tag>([^<\r\n]+)', caseSensitive: false)
        .firstMatch(block);
    return match?.group(1)?.trim();
  }

  final rows = <List<String>>[
    ['Date', 'Amount', 'Description'],
  ];
  final transactions = RegExp(
    r'<STMTTRN>(.*?)(?:</STMTTRN>|(?=<STMTTRN>)|$)',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(content);

  for (final match in transactions) {
    final block = match.group(1)!;
    final rawDate = tagValue(block, 'DTPOSTED');
    final amount = tagValue(block, 'TRNAMT');
    final name = tagValue(block, 'NAME') ?? tagValue(block, 'MEMO') ?? '';
    if (rawDate == null || amount == null || rawDate.length < 8) continue;
    final date = '${rawDate.substring(0, 4)}-'
        '${rawDate.substring(4, 6)}-${rawDate.substring(6, 8)}';
    rows.add([date, amount, name]);
  }
  return rows.length > 1 ? rows : const [];
}

/// Минимальный XLSX-ридер: первый лист книги. Понимает sharedStrings,
/// inline-строки и числа; серийные даты Excel конвертирует
/// `parseStatementDate` на следующем шаге.
List<List<String>> parseXlsx(Uint8List bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    return const [];
  }

  String? fileContent(String path) {
    for (final file in archive.files) {
      if (file.name == path) {
        return utf8.decode(file.content as List<int>, allowMalformed: true);
      }
    }
    return null;
  }

  // Таблица общих строк.
  final shared = <String>[];
  final sharedXml = fileContent('xl/sharedStrings.xml');
  if (sharedXml != null) {
    for (final si in RegExp(r'<si>(.*?)</si>', dotAll: true)
        .allMatches(sharedXml)) {
      final texts = RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true)
          .allMatches(si.group(1)!)
          .map((m) => _unescapeXml(m.group(1)!))
          .join();
      shared.add(texts);
    }
  }

  final sheetXml = fileContent('xl/worksheets/sheet1.xml');
  if (sheetXml == null) return const [];

  int columnIndex(String cellRef) {
    var index = 0;
    for (final code in cellRef.codeUnits) {
      if (code >= 65 && code <= 90) {
        index = index * 26 + (code - 64);
      } else {
        break;
      }
    }
    return index - 1;
  }

  final rows = <List<String>>[];
  for (final rowMatch in RegExp(r'<row[^>]*>(.*?)</row>', dotAll: true)
      .allMatches(sheetXml)) {
    final cells = <int, String>{};
    for (final cell in RegExp(
      r'<c\s+([^>]*)>(.*?)</c>|<c\s+([^>]*)/>',
      dotAll: true,
    ).allMatches(rowMatch.group(1)!)) {
      final attrs = cell.group(1) ?? cell.group(3) ?? '';
      final body = cell.group(2) ?? '';
      final ref =
          RegExp(r'r="([A-Z]+)\d+"').firstMatch(attrs)?.group(1);
      if (ref == null) continue;
      final type = RegExp(r't="(\w+)"').firstMatch(attrs)?.group(1);

      String value = '';
      final v = RegExp(r'<v>(.*?)</v>', dotAll: true).firstMatch(body);
      if (type == 's' && v != null) {
        final idx = int.tryParse(v.group(1)!);
        value = idx != null && idx < shared.length ? shared[idx] : '';
      } else if (type == 'inlineStr') {
        value = RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true)
                .allMatches(body)
                .map((m) => _unescapeXml(m.group(1)!))
                .join();
      } else if (v != null) {
        value = _unescapeXml(v.group(1)!);
      }
      cells[columnIndex(ref)] = value.trim();
    }
    if (cells.isEmpty) continue;
    final width = cells.keys.reduce((a, b) => a > b ? a : b) + 1;
    rows.add([for (var i = 0; i < width; i++) cells[i] ?? '']);
  }
  return rows.where((r) => r.any((c) => c.isNotEmpty)).toList();
}

String _unescapeXml(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');


/// PDF-выписка (Сбербанк и похожие текстовые выписки): извлекаем
/// текст и собираем операции эвристикой «строка с датой и суммой».
/// В сбер-выписках расходы идут без знака, приходы — с плюсом.
List<List<String>> parsePdfStatement(Uint8List bytes) {
  final text = extractPdfText(bytes);
  if (text.trim().isEmpty) return const [];

  final rows = <List<String>>[
    ['Date', 'Amount', 'Description'],
  ];
  final lines = text.split('\n');
  final dateRe = RegExp(r'\d{2}\.\d{2}\.\d{4}');
  final moneyRe = RegExp(r'[+-]?\d[\d  ]*,\d{2}');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final date = dateRe.firstMatch(line);
    if (date == null) continue;
    final amounts = moneyRe.allMatches(line).toList();
    if (amounts.isEmpty) continue;

    // Первая денежная группа — сумма операции (дальше может идти
    // остаток по счёту).
    final rawAmount = amounts.first.group(0)!;
    final normalized = rawAmount
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    final signed = normalized.startsWith('+')
        ? normalized.substring(1)
        : normalized.startsWith('-')
            ? normalized
            : '-$normalized';

    // Описание: строка без дат, кода авторизации и денежных групп;
    // если почти пусто — добавляем следующую строку без даты.
    var description = line
        .replaceAll(dateRe, ' ')
        .replaceAll(moneyRe, ' ')
        .replaceAll(RegExp(r'\b\d{5,}\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (description.length < 4 &&
        i + 1 < lines.length &&
        !dateRe.hasMatch(lines[i + 1])) {
      description =
          ('$description ${lines[i + 1]}').replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    rows.add([date.group(0)!, signed, description]);
  }
  return rows.length > 1 ? rows : const [];
}
