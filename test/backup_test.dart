import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/backup.dart';
import 'package:numo/models/category.dart';
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

    final decoded = Backup.decode(
        Backup.encode(transactions: txs, categories: Categories.defaults));

    expect(decoded.transactions.length, 2);
    expect(decoded.transactions.first.id, '1'); // сортировка по дате
    expect(decoded.transactions.first.amount, 1500.50);
    expect(decoded.categories.length, Categories.defaults.length);
    expect(decoded.categories.byId('cafe').title, 'Кафе и рестораны');
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
