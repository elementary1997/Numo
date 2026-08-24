import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/pdf_text.dart';
import 'package:numo/data/statement_parsers.dart';

/// Собирает минимальный PDF-подобный документ: контент-поток c
/// FlateDecode и ToUnicode CMap — ровно те конструкции, которые
/// разбирает extractPdfText.
Uint8List buildTestPdf({
  required String contentStream,
  String? cmap,
}) {
  final buffer = BytesBuilder();
  buffer.add(latin1.encode('%PDF-1.4\n'));

  void addStream(String dict, List<int> data) {
    buffer.add(latin1.encode('$dict\nstream\n'));
    buffer.add(data);
    buffer.add(latin1.encode('\nendstream\n'));
  }

  final compressed = const ZLibEncoder().encode(latin1.encode(contentStream));
  addStream('<< /Length ${compressed.length} /Filter /FlateDecode >>',
      compressed);
  if (cmap != null) {
    addStream('<< /Length ${cmap.length} >>', latin1.encode(cmap));
  }
  buffer.add(latin1.encode('%%EOF\n'));
  return buffer.toBytes();
}

void main() {
  test('извлекает латиницу из Tj/TJ и переносит строки на Td', () {
    final pdf = buildTestPdf(
      contentStream: 'BT /F1 10 Tf (Hello ) Tj [(wor) (ld)] TJ '
          '0 -12 Td (Second line 123,45) Tj ET',
    );
    final text = extractPdfText(pdf);
    expect(text, contains('Hello world'));
    expect(text, contains('\nSecond line 123,45'));
  });

  test('декодирует кириллицу через ToUnicode CMap (hex-строки)', () {
    // Коды 0001..0004 → «Кафе» (UTF-16BE).
    const cmap = '''
begincmap
4 beginbfchar
<0001> <041A>
<0002> <0430>
<0003> <0444>
<0004> <0435>
endbfchar
endcmap
''';
    final pdf = buildTestPdf(
      contentStream: 'BT <00010002000300 04> Tj ET',
      cmap: cmap,
    );
    final text = extractPdfText(pdf);
    expect(text, contains('Кафе'));
  });

  test('bfrange разворачивается в диапазон кодов', () {
    const cmap = '''
1 beginbfrange
<0010> <0012> <0410>
endbfrange
''';
    final pdf = buildTestPdf(
      contentStream: 'BT <001000110012> Tj ET',
      cmap: cmap,
    );
    expect(extractPdfText(pdf), contains('АБВ'));
  });

  test('parsePdfStatement: сбер-строки с датой и суммами', () {
    final pdf = buildTestPdf(
      contentStream: 'BT '
          '(01.08.2026 01.08.2026 123456 Supermarkety 350,50 24 649,50) Tj '
          '0 -12 Td (PYATEROCHKA 1234) Tj '
          '0 -12 Td (05.08.2026 05.08.2026 654321 Perevody +145 000,00 169 649,50) Tj '
          '0 -12 Td (Zarplata) Tj '
          'ET',
    );
    final rows = parsePdfStatement(pdf);
    expect(rows.first, ['Date', 'Amount', 'Description']);
    expect(rows[1][0], '01.08.2026');
    expect(rows[1][1], '-350.50'); // расход без знака → минус
    expect(rows[1][2], contains('Supermarkety'));
    expect(rows[2][1], '145000.00'); // приход с плюсом
    expect(rows[2][2], contains('Perevody'));
  });

  test('сбер-выписка по карте: дата+время, категория, сумма, описание',
      () {
    // Текст в том виде, в каком его отдаёт extractPdfText для настоящей
    // выписки СберБанка: колонки слипаются, операции идут подряд.
    const text = 'Сумма в валютеоперации2'
        '24.08.2026\n10:46\nСупермаркеты\n672,94\n'
        '24.08.2026\n269192\nPYATEROCHKA 5026 Dzerzhinsk RUS. '
        'Операция по карте ****6585\n'
        '18.08.202619:26Перевод СБП2 560,0018.08.2026353755'
        'Перевод в Ozon Bank (Ozon). Операция по карте ****6585\n'
        '10.08.202612:00Пополнение1 000,0010.08.2026111111'
        'Перевод из другого банка. Операция по карте ****6585'
        'Продолжение на следующей странице';
    final rows = parseSberCardStatement(text);
    expect(rows.length, 4);
    expect(rows[1], [
      '24.08.2026',
      '-672.94',
      'Супермаркеты · PYATEROCHKA 5026 Dzerzhinsk RUS',
    ]);
    expect(rows[2], [
      '18.08.2026',
      '-2560.00',
      'Перевод СБП · Перевод в Ozon Bank (Ozon)',
    ]);
    // Пополнение — приход, без минуса; колонтитул отрезан.
    expect(rows[3], [
      '10.08.2026',
      '1000.00',
      'Пополнение · Перевод из другого банка',
    ]);
  });

  test('detectFormat узнаёт PDF по заголовку', () {
    expect(
      detectFormat('statement.pdf',
          Uint8List.fromList(latin1.encode('%PDF-1.7\n...'))),
      StatementFormat.pdf,
    );
  });
}
