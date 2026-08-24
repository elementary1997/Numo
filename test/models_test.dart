import 'package:flutter/material.dart';
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
      expect(Categories.defaults.byId('cafe').title, 'Кафе и рестораны');
    });

    test('byId с неизвестным id даёт «Прочее», а не падает', () {
      expect(Categories.defaults.byId('unknown'), Categories.other);
    });

    test('у всех встроенных категорий валидные ключи иконок', () {
      for (final c in Categories.defaults) {
        expect(CategoryIcons.byKey.containsKey(c.iconKey), isTrue,
            reason: 'нет иконки для ${c.id}');
      }
    });

    test('JSON round-trip сохраняет все поля категории', () {
      const original = TxCategory(
        id: 'user-1',
        title: 'Хобби',
        iconKey: 'music',
        color: Color(0xFF6BA8FF),
        isIncome: false,
        archived: true,
      );
      final restored = TxCategory.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.iconKey, original.iconKey);
      expect(restored.color, original.color);
      expect(restored.isIncome, original.isIncome);
      expect(restored.archived, original.archived);
    });
  });
}
