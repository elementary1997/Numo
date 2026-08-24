// Отладка PDF-выписок: dart run tool/pdf_extract_debug.dart <file.pdf>
// Печатает извлечённый текст и разобранные операции.
import 'dart:io';

import 'package:numo/data/pdf_text.dart';
import 'package:numo/data/statement_parsers.dart';

void main(List<String> args) {
  final bytes = File(args[0]).readAsBytesSync();
  final text = extractPdfText(bytes);
  stdout.writeln('=== text: ${text.length} chars ===');
  stdout.writeln(text.length > 2000 ? text.substring(0, 2000) : text);
  final rows = parsePdfStatement(bytes);
  stdout.writeln('=== rows: ${rows.length} ===');
  var sum = 0.0;
  for (final r in rows.skip(1)) {
    stdout.writeln(r.join(' | '));
    sum += double.tryParse(r[1]) ?? 0;
  }
  stdout.writeln('=== total: ${sum.toStringAsFixed(2)} ===');
}
