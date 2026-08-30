import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/members_repository.dart';
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

  test('миграция v8 → v9: данные целы, поля общих счетов появились',
      () async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });

    // База в состоянии схемы 8: без updated_at/deleted_at/author_id,
    // без флага shared у счетов и без таблицы участников.
    final executor = NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE transaction_rows (
          id TEXT NOT NULL PRIMARY KEY,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          category_id TEXT NOT NULL,
          date INTEGER NOT NULL,
          note TEXT NOT NULL DEFAULT '',
          account_id TEXT NOT NULL DEFAULT 'main'
        );
      ''');
      raw.execute('''
        CREATE TABLE account_rows (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          icon_key TEXT NOT NULL,
          color INTEGER NOT NULL,
          currency TEXT NOT NULL DEFAULT 'RUB',
          archived INTEGER NOT NULL DEFAULT 0,
          kind TEXT NOT NULL DEFAULT 'regular',
          rate REAL,
          opened_at INTEGER,
          closes_at INTEGER
        );
      ''');
      raw.execute(
          "INSERT INTO transaction_rows VALUES ('old', 'expense', 700, "
          "'groceries', 1786000000, 'Пятёрочка', 'main');");
      raw.execute(
          "INSERT INTO account_rows (id, title, icon_key, color) "
          "VALUES ('main', 'Основной', 'savings', 123);");
      raw.execute('PRAGMA user_version = 8;');
    });

    final db = NumoDatabase(executor);
    addTearDown(db.close);

    final repo = await TransactionsRepository.open(db, seedDemo: false);
    final tx = repo.loadAll().single;
    expect(tx.id, 'old');
    expect(tx.note, 'Пятёрочка');
    // Старая запись не имеет отметки изменения — за неё сходит дата.
    expect(tx.updatedAt, isNull);
    expect(tx.changedAt, tx.date);
    expect(tx.isDeleted, isFalse);

    final accounts = await AccountsRepository.open(db);
    expect(accounts.loadAll().single.shared, isFalse);

    // Справочник участников создан миграцией и заводит «меня».
    final members = await MembersRepository.open(db, meName: 'Я');
    expect(members.me!.name, 'Я');
  });
}
