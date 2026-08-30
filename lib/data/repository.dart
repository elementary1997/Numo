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

  /// Сколько живут «надгробия» удалённых операций: за это время
  /// участник общего счёта успевает получить их через облако.
  static const tombstoneLifetime = Duration(days: 180);

  static Future<TransactionsRepository> open(NumoDatabase db,
      {String seedLocale = 'ru', bool seedDemo = true}) async {
    await _purgeOldTombstones(db);
    await _fillMissingNoteLower(db);
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
      } else if (seedDemo) {
        await repo.saveAll(demoData(seedLocale: seedLocale));
      }
      await prefs.setBool(_migratedKey, true);
    }
    return repo;
  }

  /// Живые операции; удалённые остаются в базе надгробиями и наружу
  /// не показываются.
  List<Tx> loadAll() =>
      List.unmodifiable(_cache.where((t) => !t.isDeleted));

  /// Выборка ленты операций средствами SQLite: фильтры, поиск и
  /// постраничность считает база по индексам, а не приложение полным
  /// проходом по списку на каждый кадр.
  ///
  /// [query] ищет по заметке без учёта регистра; [categoryIds] сужает
  /// до набора категорий (поиск по названию категории экран собирает
  /// сам, ему видны локализованные имена).
  Future<List<Tx>> page({
    String query = '',
    DateTime? from,
    DateTime? to,
    TxType? type,
    String? accountId,
    Set<String>? categoryIds,
    int limit = 50,
    int offset = 0,
  }) async {
    final select = _db.select(_db.transactionRows)
      ..where((row) => row.deletedAt.isNull());
    if (from != null) {
      select.where((row) => row.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      select.where((row) => row.date.isSmallerOrEqualValue(to));
    }
    if (type != null) {
      select.where((row) => row.type.equals(type.name));
    }
    if (accountId != null) {
      select.where((row) => row.accountId.equals(accountId));
    }
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final pattern = '%${trimmed.toLowerCase()}%';
      if (categoryIds == null || categoryIds.isEmpty) {
        select.where((row) => row.noteLower.like(pattern));
      } else {
        // Совпало описание — или категория, чьё название подошло.
        select.where((row) =>
            row.noteLower.like(pattern) |
            row.categoryId.isIn(categoryIds.toList()));
      }
    }
    select
      ..orderBy([(row) => OrderingTerm.desc(row.date)])
      ..limit(limit, offset: offset);
    return (await select.get()).map(_fromRow).toList();
  }

  /// Всё, включая надгробия — для публикации в общую папку (ADR-0014).
  List<Tx> allRows() => List.unmodifiable(_cache);

  /// Полная замена набора — только для восстановления из бэкапа,
  /// синхронизации и массовой переклассификации. Для обычных
  /// добавлений/правок использовать [upsert]/[removeById]: они не
  /// переписывают всю таблицу.
  Future<void> saveAll(List<Tx> transactions) async {
    _cache = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    await _db.transaction(() async {
      await _db.delete(_db.transactionRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.transactionRows, _cache.map(_toRow));
      });
    });
  }

  /// Точечная вставка/обновление: одна батч-запись затронутых строк
  /// вместо перезаписи всей таблицы.
  /// [touch] переставляет отметку изменения на «сейчас» — так ведёт
  /// себя любая локальная правка. Восстановление данных передаёт
  /// `touch: false`, чтобы сохранить исходные отметки для слияния.
  Future<void> upsertAll(
    List<Tx> transactions, {
    String? authorId,
    bool touch = true,
  }) async {
    if (transactions.isEmpty) return;
    final now = DateTime.now();
    // Отметка изменения и автор нужны слиянию общих счетов (ADR-0014).
    final stamped = [
      for (final tx in transactions)
        tx.copyWith(
          updatedAt: touch ? now : (tx.updatedAt ?? now),
          authorId: tx.authorId ?? authorId,
        ),
    ];
    final ids = {for (final t in stamped) t.id};
    _cache = [
      ...stamped,
      ..._cache.where((t) => !ids.contains(t.id)),
    ]..sort((a, b) => b.date.compareTo(a.date));
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
          _db.transactionRows, stamped.map(_toRow));
    });
  }

  Future<void> upsert(Tx tx, {String? authorId}) =>
      upsertAll([tx], authorId: authorId);

  /// Мягкое удаление: строка остаётся надгробием, иначе файл второго
  /// участника общего счёта воскресил бы операцию при слиянии.
  Future<void> removeById(String id) async {
    final now = DateTime.now();
    Tx? removed;
    _cache = [
      for (final t in _cache)
        if (t.id == id)
          removed = t.copyWith(deletedAt: now, updatedAt: now)
        else
          t,
    ];
    final tombstone = removed;
    if (tombstone == null) return;
    await _db.update(_db.transactionRows).replace(_toRow(tombstone));
  }

  /// Слияние операций из файлов других участников (ADR-0014):
  /// побеждает более поздняя отметка изменения, при равенстве —
  /// запись с большим `authorId`, чтобы результат не зависел от
  /// порядка чтения файлов. Возвращает число применённых изменений.
  Future<int> mergeAll(Iterable<Tx> incoming) async {
    final byId = {for (final t in _cache) t.id: t};
    final changed = <Tx>[];
    for (final remote in incoming) {
      final local = byId[remote.id];
      if (local == null || _remoteWins(local, remote)) {
        byId[remote.id] = remote;
        changed.add(remote);
      }
    }
    if (changed.isEmpty) return 0;
    _cache = byId.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
          _db.transactionRows, changed.map(_toRow).toList());
    });
    return changed.length;
  }

  static bool _remoteWins(Tx local, Tx remote) {
    final diff = remote.changedAt.compareTo(local.changedAt);
    if (diff != 0) return diff > 0;
    return (remote.authorId ?? '').compareTo(local.authorId ?? '') > 0;
  }

  /// Заполняет поисковую колонку у строк, записанных до её появления.
  /// Нижний регистр для кириллицы умеет только Dart, поэтому обновление
  /// идёт через приложение, а не одним UPDATE.
  static Future<void> _fillMissingNoteLower(NumoDatabase db) async {
    final stale = await (db.select(db.transactionRows)
          ..where((row) => row.noteLower.equals('') & row.note.equals('').not()))
        .get();
    if (stale.isEmpty) return;
    await db.batch((batch) {
      for (final row in stale) {
        batch.update(
          db.transactionRows,
          TransactionRowsCompanion(noteLower: Value(row.note.toLowerCase())),
          where: (t) => t.id.equals(row.id),
        );
      }
    });
  }

  static Future<void> _purgeOldTombstones(NumoDatabase db) async {
    final cutoff = DateTime.now().subtract(tombstoneLifetime);
    await (db.delete(db.transactionRows)
          ..where((row) => row.deletedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  static Tx _fromRow(TransactionRow row) => Tx(
        id: row.id,
        type: TxType.values.byName(row.type),
        amount: row.amount,
        categoryId: row.categoryId,
        date: row.date,
        accountId: row.accountId,
        note: row.note,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        authorId: row.authorId,
      );

  static TransactionRowsCompanion _toRow(Tx tx) => TransactionRowsCompanion(
        id: Value(tx.id),
        type: Value(tx.type.name),
        amount: Value(tx.amount),
        categoryId: Value(tx.categoryId),
        date: Value(tx.date),
        accountId: Value(tx.accountId),
        note: Value(tx.note),
        noteLower: Value(tx.note.toLowerCase()),
        updatedAt: Value(tx.updatedAt),
        deletedAt: Value(tx.deletedAt),
        authorId: Value(tx.authorId),
      );

  /// Демо-данные первого запуска: пример живого месяца, чтобы дашборд
  /// и аналитика сразу были наглядными. Удаляются как обычные операции.
  static List<Tx> demoData({String seedLocale = 'ru'}) {
    String t(String ru, String en) => seedLocale == 'ru' ? ru : en;
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

    earn(21, Categories.salary, 145000, t('Аванс', 'Advance'));
    earn(6, Categories.salary, 145000, t('Зарплата', 'Salary'));
    earn(12, Categories.freelance, 30000, t('Проект на стороне', 'Side project'));

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
    spend(2, Categories.entertainment, 1800, t('Кино', 'Movies'));
    spend(4, Categories.shopping, 6400, t('Кроссовки', 'Sneakers'));
    spend(9, Categories.health, 3200, t('Аптека', 'Pharmacy'));
    spend(15, Categories.home, 8900, t('Коммуналка', 'Utilities'));
    spend(18, Categories.entertainment, 2500, t('Концерт', 'Concert'));
    spend(24, Categories.shopping, 4300, t('Подарок', 'Gift'));

    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }
}
