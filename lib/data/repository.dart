import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import 'database.dart';

/// Хранилище операций поверх drift/SQLite с write-through кэшем:
/// чтение синхронное из памяти, запись — транзакцией в базу.
///
/// При первом запуске после обновления однократно переносит данные
/// из старого хранилища (JSON в shared_preferences, ключ
/// `numo.transactions.v1`); на чистой установке сидирует демо-данные.
class TransactionsRepository {
  TransactionsRepository._(this._db, List<Tx> cache) : _cache = cache;

  static const legacyKey = 'numo.transactions.v1';
  static const _migratedKey = 'numo.transactions.migrated-to-drift.v1';

  final NumoDatabase _db;
  List<Tx> _cache;

  static Future<TransactionsRepository> open(NumoDatabase db) async {
    final rows = await db.select(db.transactionRows).get();
    if (rows.isNotEmpty) {
      final cache = rows.map(_fromRow).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return TransactionsRepository._(db, cache);
    }

    final prefs = await SharedPreferences.getInstance();
    final repo = TransactionsRepository._(db, []);
    if (!(prefs.getBool(_migratedKey) ?? false)) {
      final legacy = prefs.getString(legacyKey);
      if (legacy != null && legacy.isNotEmpty) {
        final migrated = (jsonDecode(legacy) as List)
            .map((e) => Tx.fromJson(e as Map<String, dynamic>))
            .toList();
        await repo.saveAll(migrated);
      } else {
        await repo.saveAll(demoData());
      }
      await prefs.setBool(_migratedKey, true);
    }
    return repo;
  }

  List<Tx> loadAll() => List.unmodifiable(_cache);

  Future<void> saveAll(List<Tx> transactions) async {
    _cache = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    await _db.transaction(() async {
      await _db.delete(_db.transactionRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.transactionRows, _cache.map(_toRow));
      });
    });
  }

  static Tx _fromRow(TransactionRow row) => Tx(
        id: row.id,
        type: TxType.values.byName(row.type),
        amount: row.amount,
        categoryId: row.categoryId,
        date: row.date,
        accountId: row.accountId,
        note: row.note,
      );

  static TransactionRowsCompanion _toRow(Tx tx) => TransactionRowsCompanion(
        id: Value(tx.id),
        type: Value(tx.type.name),
        amount: Value(tx.amount),
        categoryId: Value(tx.categoryId),
        date: Value(tx.date),
        accountId: Value(tx.accountId),
        note: Value(tx.note),
      );

  /// Демо-данные первого запуска: пример живого месяца, чтобы дашборд
  /// и аналитика сразу были наглядными. Удаляются как обычные операции.
  static List<Tx> demoData() {
    final rng = Random(7);
    final now = DateTime.now();
    final txs = <Tx>[];
    var id = 0;
    String nextId() => 'demo-${id++}';

    void spend(int daysAgo, TxCategory cat, double amount, [String note = '']) {
      txs.add(Tx(
        id: nextId(),
        type: TxType.expense,
        amount: amount,
        categoryId: cat.id,
        date: DateTime(now.year, now.month, now.day - daysAgo,
            9 + rng.nextInt(12), rng.nextInt(60)),
        note: note,
      ));
    }

    void earn(int daysAgo, TxCategory cat, double amount, [String note = '']) {
      txs.add(Tx(
        id: nextId(),
        type: TxType.income,
        amount: amount,
        categoryId: cat.id,
        date: DateTime(now.year, now.month, now.day - daysAgo, 10),
        note: note,
      ));
    }

    earn(21, Categories.salary, 145000, 'Аванс');
    earn(6, Categories.salary, 145000, 'Зарплата');
    earn(12, Categories.freelance, 30000, 'Проект на стороне');

    for (var d = 0; d < 28; d++) {
      if (d % 2 == 0) {
        spend(d, Categories.groceries, 700 + rng.nextInt(1800).toDouble());
      }
      if (d % 3 == 0) {
        spend(d, Categories.transport, 120 + rng.nextInt(400).toDouble());
      }
      if (d % 5 == 1) {
        spend(d, Categories.cafe, 900 + rng.nextInt(2200).toDouble());
      }
    }
    spend(2, Categories.entertainment, 1800, 'Кино');
    spend(4, Categories.shopping, 6400, 'Кроссовки');
    spend(9, Categories.health, 3200, 'Аптека');
    spend(15, Categories.home, 8900, 'Коммуналка');
    spend(18, Categories.entertainment, 2500, 'Концерт');
    spend(24, Categories.shopping, 4300, 'Подарок');

    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }
}
