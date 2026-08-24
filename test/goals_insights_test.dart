import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/insights.dart';
import 'package:numo/data/statement_parsers.dart';
import 'package:numo/l10n/app_localizations_ru.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/goal.dart';
import 'package:numo/models/transaction.dart';

void main() {
  group('Goal', () {
    final goal = Goal(
      id: 'g1',
      title: 'Отпуск',
      iconKey: 'beach',
      color: const Color(0xFF3DDC97),
      targetAmount: 120000,
      savedAmount: 30000,
      deadline: DateTime(2027, 2, 24),
    );

    test('прогресс и остаток', () {
      expect(goal.progress, closeTo(0.25, 0.001));
      expect(goal.remaining, 90000);
      expect(goal.reached, isFalse);
    });

    test('месячный темп до дедлайна', () {
      // 90 000 за ~6 месяцев ≈ 15 000/мес.
      final monthly = goal.monthlyNeeded(now: DateTime(2026, 8, 24))!;
      expect(monthly, closeTo(15000, 1000));
    });

    test('достигнутая цель не требует темпа', () {
      final done = goal.copyWith(savedAmount: 120000);
      expect(done.reached, isTrue);
      expect(done.monthlyNeeded(now: DateTime(2026, 8, 24)), isNull);
    });

    test('JSON round-trip', () {
      final restored = Goal.fromJson(goal.toJson());
      expect(restored.targetAmount, 120000);
      expect(restored.savedAmount, 30000);
      expect(restored.deadline, DateTime(2027, 2, 24));
    });
  });

  group('buildInsights', () {
    final l10n = AppLocalizationsRu();
    final now = DateTime(2026, 8, 24);

    Tx tx(String id, double amount,
            {bool income = false,
            String category = 'groceries',
            required DateTime date,
            String note = ''}) =>
        Tx(
          id: id,
          type: income ? TxType.income : TxType.expense,
          amount: amount,
          categoryId: category,
          date: date,
          note: note,
        );

    test('норма сбережений, топ-категория, рост к прошлому месяцу', () {
      final txs = [
        tx('i1', 100000, income: true, category: 'salary',
            date: DateTime(2026, 8, 5)),
        tx('e1', 30000, date: DateTime(2026, 8, 10)),
        tx('e2', 10000, category: 'cafe', date: DateTime(2026, 8, 12)),
        // прошлый месяц: кафе было заметно меньше
        tx('p1', 4000, category: 'cafe', date: DateTime(2026, 7, 12)),
        tx('p2', 30000, date: DateTime(2026, 7, 10)),
      ];
      final insights = buildInsights(
        l10n: l10n,
        transactions: txs,
        categories: Categories.defaults,
        budgets: const {},
        now: now,
      );
      final texts = insights.map((i) => i.text).join('\n');
      expect(texts, contains('60%')); // (100000-40000)/100000
      expect(texts, contains('Продукты')); // топ-категория
      expect(texts, contains('Кафе и рестораны')); // рост
      expect(
          insights.any((i) => i.tone == InsightTone.warn), isTrue);
    });

    test('переводы и корректировки не попадают в статистику', () {
      final txs = [
        tx('a1', 500000, category: 'adjustment',
            income: true, date: DateTime(2026, 8, 1)),
        tx('t1', 100000, category: 'transfer', date: DateTime(2026, 8, 2)),
        tx('i1', 50000, income: true, category: 'salary',
            date: DateTime(2026, 8, 5)),
        tx('e1', 10000, date: DateTime(2026, 8, 6)),
      ];
      final insights = buildInsights(
        l10n: l10n,
        transactions: txs,
        categories: Categories.defaults,
        budgets: const {},
        now: now,
      );
      final texts = insights.map((i) => i.text).join('\n');
      expect(texts, contains('80%')); // (50000-10000)/50000
    });
  });

  group('statement parsers', () {
    test('detectFormat по сигнатурам', () {
      expect(
          detectFormat('a.xlsx',
              Uint8List.fromList([0x50, 0x4B, 0x03, 0x04, 0, 0])),
          StatementFormat.xlsx);
      expect(
          detectFormat('statement.ofx',
              Uint8List.fromList('OFXHEADER:100\n<OFX>'.codeUnits)),
          StatementFormat.ofx);
      expect(
          detectFormat('data.csv',
              Uint8List.fromList('Дата;Сумма\n'.codeUnits)),
          StatementFormat.csv);
    });

    test('parseOfx: STMTTRN в таблицу с заголовком', () {
      const ofx = '''
OFXHEADER:100
<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><BANKTRANLIST>
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20260810120000
<TRNAMT>-350.50
<NAME>PYATEROCHKA 1234
</STMTTRN>
<STMTTRN>
<TRNTYPE>CREDIT
<DTPOSTED>20260805
<TRNAMT>145000.00
<MEMO>SALARY
</STMTTRN>
</BANKTRANLIST></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>''';
      final rows = parseOfx(ofx);
      expect(rows.first, ['Date', 'Amount', 'Description']);
      expect(rows[1], ['2026-08-10', '-350.50', 'PYATEROCHKA 1234']);
      expect(rows[2], ['2026-08-05', '145000.00', 'SALARY']);
    });
  });
}
