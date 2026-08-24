import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/backup.dart';
import 'package:numo/models/account.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/recurring.dart';
import 'package:numo/models/transaction.dart';

void main() {
  test('бэкап: encode → decode возвращает те же данные', () {
    final txs = [
      Tx(
        id: '1',
        type: TxType.expense,
        amount: 1500.50,
        categoryId: 'groceries',
        date: DateTime(2026, 8, 24, 12, 30),
        note: 'Магазин',
      ),
      Tx(
        id: '2',
        type: TxType.income,
        amount: 145000,
        categoryId: 'salary',
        date: DateTime(2026, 8, 20),
      ),
    ];

    final decoded = Backup.decode(Backup.encode(BackupData(
      transactions: txs,
      categories: Categories.defaults,
      accounts: const [Accounts.main],
      budgets: const {'groceries': 25000},
      recurring: [
        RecurringRule(
          id: 'r1',
          type: TxType.expense,
          amount: 500,
          categoryId: 'home',
          dayOfMonth: 5,
          startDate: DateTime(2026, 6),
          appliedThrough: DateTime(2026, 8, 24),
        ),
      ],
    )));

    expect(decoded.transactions.length, 2);
    expect(decoded.transactions.first.id, '1'); // сортировка по дате
    expect(decoded.transactions.first.amount, 1500.50);
    expect(decoded.categories.length, Categories.defaults.length);
    expect(decoded.categories.byId('cafe').title, 'Кафе и рестораны');
    expect(decoded.accounts.single.id, 'main');
    expect(decoded.budgets, {'groceries': 25000.0});
    expect(decoded.recurring.single.dayOfMonth, 5);
    expect(decoded.recurring.single.appliedThrough, DateTime(2026, 8, 24));
  });

  test('бэкап v1 (без счетов и бюджетов) читается с пустыми полями', () {
    const v1 = '{"app": "numo", "version": 1, "categories": [], '
        '"transactions": []}';
    final decoded = Backup.decode(v1);
    expect(decoded.accounts, isEmpty);
    expect(decoded.budgets, isEmpty);
    expect(decoded.recurring, isEmpty);
  });

  test('decode отклоняет не-JSON с понятной ошибкой', () {
    expect(
      () => Backup.decode('это не json'),
      throwsA(isA<FormatException>()),
    );
  });

  test('decode отклоняет чужой JSON', () {
    expect(
      () => Backup.decode('{"foo": 1}'),
      throwsA(predicate(
          (e) => e is FormatException && e.message.contains('Numo'))),
    );
  });

  test('decode отклоняет бэкап из будущей версии', () {
    expect(
      () => Backup.decode(
          '{"app": "numo", "version": 99, "categories": [], "transactions": []}'),
      throwsA(predicate((e) =>
          e is FormatException && e.message.contains('новой версией'))),
    );
  });
}
