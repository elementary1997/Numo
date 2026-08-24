import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('операции переезжают из shared_preferences в drift один раз',
      () async {
    final legacy = [
      Tx(
        id: 'old-1',
        type: TxType.expense,
        amount: 250,
        categoryId: 'cafe',
        date: DateTime(2026, 7, 10, 13),
        note: 'Обед',
      ),
    ];
    SharedPreferences.setMockInitialValues({
      TransactionsRepository.legacyKey:
          jsonEncode(legacy.map((t) => t.toJson()).toList()),
    });

    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = await TransactionsRepository.open(db);
    expect(repo.loadAll().single.id, 'old-1');
    expect(repo.loadAll().single.note, 'Обед');

    // Пользователь всё удалил — при следующем открытии демо-данные
    // не должны появиться снова.
    await repo.saveAll([]);
    final reopened = await TransactionsRepository.open(db);
    expect(reopened.loadAll(), isEmpty);
  });

  test('чистая установка сидируется демо-данными', () async {
    SharedPreferences.setMockInitialValues({});
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = await TransactionsRepository.open(db);
    expect(repo.loadAll(), isNotEmpty);
  });

  test('категории переезжают из shared_preferences, иначе сидируются',
      () async {
    SharedPreferences.setMockInitialValues({
      CategoriesRepository.legacyKey: jsonEncode([
        Categories.other.toJson(),
        Categories.salary.copyWith(title: 'Основная работа').toJson(),
      ]),
    });
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = await CategoriesRepository.open(db);
    expect(repo.loadAll().length, 2);
    expect(repo.loadAll().byId('salary').title, 'Основная работа');

    SharedPreferences.setMockInitialValues({});
    final db2 = NumoDatabase(NativeDatabase.memory());
    addTearDown(db2.close);
    final seeded = await CategoriesRepository.open(db2);
    expect(seeded.loadAll().length, Categories.defaults.length);
  });
}
