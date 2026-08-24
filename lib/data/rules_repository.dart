import 'package:drift/drift.dart';

import '../models/category_rule.dart';
import 'database.dart';

/// Хранилище правил автокатегоризации; write-through паттерн.
class RulesRepository {
  RulesRepository._(this._db, List<CategoryRule> cache) : _cache = cache;

  final NumoDatabase _db;
  List<CategoryRule> _cache;

  static Future<RulesRepository> open(NumoDatabase db) async {
    final rows = await db.select(db.categoryRuleRows).get();
    return RulesRepository._(
      db,
      [
        for (final row in rows)
          CategoryRule(
            id: row.id,
            pattern: row.pattern,
            categoryId: row.categoryId,
          ),
      ],
    );
  }

  List<CategoryRule> loadAll() => List.unmodifiable(_cache);

  Future<void> saveAll(List<CategoryRule> rules) async {
    _cache = [...rules];
    await _db.transaction(() async {
      await _db.delete(_db.categoryRuleRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.categoryRuleRows, [
          for (final rule in _cache)
            CategoryRuleRowsCompanion(
              id: Value(rule.id),
              pattern: Value(rule.pattern),
              categoryId: Value(rule.categoryId),
            ),
        ]);
      });
    });
  }
}
