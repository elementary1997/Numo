import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numo/data/settlements.dart';
import 'package:numo/models/transaction.dart';

/// «Кто кому должен» — чистый расчёт по операциям с раскладкой.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Tx paid(
    String id, {
    required String by,
    required double amount,
    required Map<String, double> split,
    bool deleted = false,
  }) =>
      Tx(
        id: id,
        type: TxType.expense,
        amount: amount,
        categoryId: 'groceries',
        date: DateTime(2026, 8, 10),
        authorId: by,
        split: split,
        deletedAt: deleted ? DateTime(2026, 8, 11) : null,
      );

  test('пополам: половина возвращается платившему', () {
    final debts = settleDebts(transactions: [
      paid('a', by: 'pasha', amount: 1000, split: splitEqually(['pasha', 'anya'])),
    ]);

    expect(debts, hasLength(1));
    expect(debts.single.from, 'anya');
    expect(debts.single.to, 'pasha');
    expect(debts.single.amount, closeTo(500, 0.01));
  });

  test('встречные траты сворачиваются в один долг', () {
    final debts = settleDebts(transactions: [
      paid('a', by: 'pasha', amount: 1000, split: splitEqually(['pasha', 'anya'])),
      paid('b', by: 'anya', amount: 600, split: splitEqually(['pasha', 'anya'])),
    ]);

    // 500 − 300 = 200 в пользу того, кто потратил больше.
    expect(debts, hasLength(1));
    expect(debts.single.from, 'anya');
    expect(debts.single.to, 'pasha');
    expect(debts.single.amount, closeTo(200, 0.01));
  });

  test('трата целиком за другого', () {
    final debts = settleDebts(transactions: [
      paid('a', by: 'pasha', amount: 700, split: {'anya': 1}),
    ]);

    expect(debts.single.amount, closeTo(700, 0.01));
    expect(debts.single.from, 'anya');
  });

  test('неравные доли', () {
    final debts = settleDebts(transactions: [
      paid('a', by: 'pasha', amount: 900, split: {'pasha': 2, 'anya': 1}),
    ]);

    expect(debts.single.amount, closeTo(300, 0.01));
  });

  test('расчёт между тремя участниками сводится к минимуму переводов', () {
    final debts = settleDebts(transactions: [
      paid('a',
          by: 'pasha',
          amount: 3000,
          split: splitEqually(['pasha', 'anya', 'oleg'])),
    ]);

    expect(debts, hasLength(2));
    expect(debts.every((d) => d.to == 'pasha'), isTrue);
    expect(debts.map((d) => d.amount),
        everyElement(closeTo(1000, 0.01)));
  });

  test('погашение долга обнуляет счёт', () {
    final debts = settleDebts(transactions: [
      paid('a', by: 'pasha', amount: 1000, split: splitEqually(['pasha', 'anya'])),
      // Аня возвращает свою половину — платит она, доля целиком на Пашу.
      paid('settle', by: 'anya', amount: 500, split: {'pasha': 1}),
    ]);

    expect(debts, isEmpty);
  });

  test('операции без раскладки и надгробия не участвуют', () {
    final debts = settleDebts(transactions: [
      Tx(
        id: 'personal',
        type: TxType.expense,
        amount: 5000,
        categoryId: 'shopping',
        date: DateTime(2026, 8, 10),
        authorId: 'pasha',
      ),
      paid('deleted',
          by: 'pasha',
          amount: 1000,
          split: splitEqually(['pasha', 'anya']),
          deleted: true),
    ]);

    expect(debts, isEmpty);
  });

  test('копеечные остатки не превращаются в долги', () {
    final debts = settleDebts(transactions: [
      paid('a', by: 'pasha', amount: 0.01, split: splitEqually(['pasha', 'anya'])),
    ]);

    expect(debts, isEmpty);
  });

  test('суммы приводятся к валюте расчёта', () {
    final debts = settleDebts(
      transactions: [
        paid('usd', by: 'pasha', amount: 100, split: splitEqually(['pasha', 'anya'])),
      ],
      // Операция в долларах: расчёт ведём в рублях.
      amountOf: (tx) => tx.amount * 90,
    );

    expect(debts.single.amount, closeTo(4500, 0.01));
  });

  group('раскладка в хранилище', () {
    test('доли переживают запись и чтение', () async {
      SharedPreferences.setMockInitialValues({
        'numo.transactions.migrated-to-drift.v1': true,
      });
      final db = NumoDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = await TransactionsRepository.open(db, seedDemo: false);

      await repo.upsertAll([
        paid('a',
            by: 'pasha',
            amount: 1000,
            split: splitEqually(['pasha', 'anya'])),
      ]);

      final reopened = await TransactionsRepository.open(db, seedDemo: false);
      final stored = reopened.loadAll().single;
      expect(stored.isSplit, isTrue);
      expect(stored.split, {'pasha': 1.0, 'anya': 1.0});

      expect(settleDebts(transactions: reopened.loadAll()).single.amount,
          closeTo(500, 0.01));
    });

    test('доли уезжают в файл общего счёта', () {
      final tx = paid('a',
          by: 'pasha', amount: 1000, split: splitEqually(['pasha', 'anya']));
      final restored = Tx.fromJson(tx.toJson());
      expect(restored.split, tx.split);
    });
  });
}
