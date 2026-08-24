import 'package:flutter_test/flutter_test.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/transaction.dart';

void main() {
  group('Tx', () {
    final tx = Tx(
      id: '1',
      type: TxType.expense,
      amount: 1500.50,
      categoryId: 'groceries',
      date: DateTime(2026, 8, 24, 12, 30),
      note: 'Магазин',
    );

    test('signedAmount: расход уменьшает баланс, доход увеличивает', () {
      expect(tx.signedAmount, -1500.50);
      expect(tx.copyWith(type: TxType.income).signedAmount, 1500.50);
    });

    test('JSON round-trip сохраняет все поля', () {
      final restored = Tx.fromJson(tx.toJson());
      expect(restored.id, tx.id);
      expect(restored.type, tx.type);
      expect(restored.amount, tx.amount);
      expect(restored.categoryId, tx.categoryId);
      expect(restored.date, tx.date);
      expect(restored.note, tx.note);
    });
  });

  group('Categories', () {
    test('byId находит категорию', () {
      expect(Categories.byId('cafe').title, 'Кафе и рестораны');
    });

    test('byId с неизвестным id даёт «Прочее», а не падает', () {
      expect(Categories.byId('unknown'), Categories.other);
    });

    test('доходные и расходные категории не пересекаются', () {
      expect(Categories.expense.every((c) => !c.isIncome), isTrue);
      expect(Categories.income.every((c) => c.isIncome), isTrue);
    });
  });
}
