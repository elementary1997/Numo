import 'dart:convert';
import 'dart:ui' show Color;

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import 'database.dart';

/// Хранилище категорий поверх drift/SQLite, тот же write-through
/// паттерн, что и у операций. Однократно переносит данные из
/// shared_preferences (ключ `numo.categories.v1`); на чистой
/// установке сидирует встроенный набор [Categories.defaults].
class CategoriesRepository {
  CategoriesRepository._(this._db, List<TxCategory> cache) : _cache = cache;

  static const legacyKey = 'numo.categories.v1';
  static const _migratedKey = 'numo.categories.migrated-to-drift.v1';

  final NumoDatabase _db;
  List<TxCategory> _cache;

  static Future<CategoriesRepository> open(NumoDatabase db,
      {String seedLocale = 'ru'}) async {
    final rows = await db.select(db.categoryRows).get();
    if (rows.isNotEmpty) {
      final repo = CategoriesRepository._(db, rows.map(_fromRow).toList());
      // Системная категория переводов появилась позже — дозаводим её
      // пользователям, сидированным до её появления.
      if (!repo._cache.any((c) => c.id == Categories.transfer.id)) {
        await repo.saveAll([...repo._cache, Categories.transfer]);
      }
      return repo;
    }

    final prefs = await SharedPreferences.getInstance();
    final repo = CategoriesRepository._(db, []);
    final legacy = prefs.getString(legacyKey);
    if (!(prefs.getBool(_migratedKey) ?? false) &&
        legacy != null &&
        legacy.isNotEmpty) {
      final migrated = (jsonDecode(legacy) as List)
          .map((e) => TxCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      await repo.saveAll(migrated);
    } else {
      // Категории нельзя удалить все до единой, поэтому пустая
      // таблица означает чистую установку.
      await repo.saveAll(Categories.defaultsFor(seedLocale));
    }
    await prefs.setBool(_migratedKey, true);
    return repo;
  }

  List<TxCategory> loadAll() => List.unmodifiable(_cache);

  Future<void> saveAll(List<TxCategory> categories) async {
    _cache = [...categories];
    await _db.transaction(() async {
      await _db.delete(_db.categoryRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.categoryRows, _cache.map(_toRow));
      });
    });
  }

  static TxCategory _fromRow(CategoryRow row) => TxCategory(
        id: row.id,
        title: row.title,
        iconKey: row.iconKey,
        color: Color(row.color),
        isIncome: row.isIncome,
        archived: row.archived,
      );

  static CategoryRowsCompanion _toRow(TxCategory c) => CategoryRowsCompanion(
        id: Value(c.id),
        title: Value(c.title),
        iconKey: Value(c.iconKey),
        color: Value(c.color.toARGB32()),
        isIncome: Value(c.isIncome),
        archived: Value(c.archived),
      );
}
