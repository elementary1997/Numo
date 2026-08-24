import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/csv.dart';
import 'package:numo/data/statement_import.dart';
import 'package:numo/models/category_rule.dart';
import 'package:numo/models/transaction.dart';

void main() {
  group('Csv', () {
    test('автоопределение разделителя', () {
      expect(Csv.detectDelimiter('Дата;Сумма;Описание'), ';');
      expect(Csv.detectDelimiter('date,amount,note'), ',');
      expect(Csv.detectDelimiter('a\tb\tc'), '\t');
      expect(Csv.detectDelimiter('"a;b",c'), ',');
    });

    test('разбор с кавычками и переводами строк внутри ячейки', () {
      final rows = Csv.parse(
          'Дата;Сумма;Описание\n01.08.2026;-100;"Кафе ""У Ашота"";\nдвор"');
      expect(rows, hasLength(2));
      expect(rows[1][2], 'Кафе "У Ашота";\nдвор');
    });

    test('write экранирует и читается обратно', () {
      final csv = Csv.write([
        ['Дата', 'Сумма'],
        ['01.08.2026', 'текст; с "кавычками"'],
      ]);
      final parsed = Csv.parse(csv);
      expect(parsed[1][1], 'текст; с "кавычками"');
    });
  });

  group('парсинг значений выписки', () {
    test('даты в разных форматах', () {
      expect(parseStatementDate('2026-08-01'), DateTime(2026, 8, 1));
      expect(parseStatementDate('01.08.2026'), DateTime(2026, 8, 1));
      expect(parseStatementDate('1/8/26'), DateTime(2026, 8, 1));
      expect(parseStatementDate('01.08.2026 14:30'),
          DateTime(2026, 8, 1, 14, 30));
      expect(parseStatementDate('не дата'), isNull);
    });

    test('суммы в русском и международном формате', () {
      expect(parseStatementAmount('1 234,56'), 1234.56);
      expect(parseStatementAmount('-1234.56'), -1234.56);
      expect(parseStatementAmount('1 234,56 ₽'), 1234.56);
      expect(parseStatementAmount('1,234.56'), 1234.56);
      expect(parseStatementAmount('мусор'), isNull);
    });
  });

  group('StatementImporter', () {
    const csvText = 'Дата;Сумма;Описание\n'
        '01.08.2026;-350,50;ПЯТЕРОЧКА 1234\n'
        '02.08.2026;-1 200;YANDEX TAXI\n'
        '05.08.2026;145 000;ЗАРПЛАТА АВГУСТ\n'
        'мусорная строка;;\n';

    final rules = [
      const CategoryRule(
          id: '1', pattern: 'пятерочка', categoryId: 'groceries'),
      const CategoryRule(id: '2', pattern: 'taxi', categoryId: 'transport'),
    ];

    test('guessMapping находит колонки по заголовку', () {
      final rows = Csv.parse(csvText);
      final mapping = StatementImporter.guessMapping(rows.first)!;
      expect(mapping.dateColumn, 0);
      expect(mapping.amountColumn, 1);
      expect(mapping.noteColumn, 2);
      expect(StatementImporter.hasHeader(rows, mapping), isTrue);
    });

    test('строки превращаются в операции с категориями по правилам', () {
      final rows = Csv.parse(csvText);
      final parsed = StatementImporter.parseRows(
        rows: rows,
        mapping: const ColumnMapping(
            dateColumn: 0, amountColumn: 1, noteColumn: 2),
        accountId: 'main',
        rules: rules,
        existingIds: const {},
        skipFirstRow: true,
      );

      expect(parsed, hasLength(4));
      final importable =
          parsed.where((r) => r.importable).map((r) => r.tx!).toList();
      expect(importable, hasLength(3));

      expect(importable[0].amount, 350.50);
      expect(importable[0].type, TxType.expense);
      expect(importable[0].categoryId, 'groceries');
      expect(importable[1].categoryId, 'transport');
      expect(importable[2].type, TxType.income);
      expect(importable[2].categoryId, 'other');
      // Мусорная строка не импортируется, но видна в предпросмотре.
      expect(parsed.last.tx, isNull);
    });

    test('повторный импорт того же файла — все строки дубликаты', () {
      final rows = Csv.parse(csvText);
      const mapping = ColumnMapping(
          dateColumn: 0, amountColumn: 1, noteColumn: 2);
      final first = StatementImporter.parseRows(
        rows: rows,
        mapping: mapping,
        accountId: 'main',
        rules: rules,
        existingIds: const {},
        skipFirstRow: true,
      );
      final imported = first
          .where((r) => r.importable)
          .map((r) => r.tx!.id)
          .toSet();

      final second = StatementImporter.parseRows(
        rows: rows,
        mapping: mapping,
        accountId: 'main',
        rules: rules,
        existingIds: imported,
        skipFirstRow: true,
      );
      expect(second.where((r) => r.importable), isEmpty);
      expect(second.where((r) => r.duplicate), hasLength(3));
    });
  });

  test('categorizeByRules: первое совпадение, без учёта регистра', () {
    final rules = [
      const CategoryRule(id: '1', pattern: 'кафе', categoryId: 'cafe'),
      const CategoryRule(id: '2', pattern: 'ка', categoryId: 'other'),
    ];
    expect(categorizeByRules('КАФЕ ПУШКИНЪ', rules), 'cafe');
    expect(categorizeByRules('вокал', rules), 'other');
    expect(categorizeByRules('ничего', rules), isNull);
  });
}
