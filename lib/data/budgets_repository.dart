import 'package:drift/drift.dart';

import 'database.dart';

/// Хранилище месячных бюджетов по категориям; тот же write-through
/// паттерн, что и у остальных репозиториев.
class BudgetsRepository {
  BudgetsRepository._(this._db, Map<String, double> cache) : _cache = cache;

  final NumoDatabase _db;
  Map<String, double> _cache;

  static Future<BudgetsRepository> open(NumoDatabase db) async {
    final rows = await db.select(db.budgetRows).get();
    return BudgetsRepository._(
      db,
      {for (final row in rows) row.categoryId: row.monthlyLimit},
    );
  }

  /// categoryId → месячный лимит.
  Map<String, double> loadAll() => Map.unmodifiable(_cache);

  /// Полная замена — используется восстановлением из бэкапа.
  Future<void> replaceAll(Map<String, double> budgets) async {
    _cache = {...budgets};
    await _db.transaction(() async {
      await _db.delete(_db.budgetRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.budgetRows, [
          for (final entry in _cache.entries)
            BudgetRowsCompanion(
              categoryId: Value(entry.key),
              monthlyLimit: Value(entry.value),
            ),
        ]);
      });
    });
  }

  /// Установить лимит; `null` удаляет бюджет категории.
  Future<void> setLimit(String categoryId, double? limit) async {
    if (limit == null) {
      _cache = {..._cache}..remove(categoryId);
      await (_db.delete(_db.budgetRows)
            ..where((row) => row.categoryId.equals(categoryId)))
          .go();
    } else {
      _cache = {..._cache, categoryId: limit};
      await _db.into(_db.budgetRows).insertOnConflictUpdate(
            BudgetRowsCompanion(
              categoryId: Value(categoryId),
              monthlyLimit: Value(limit),
            ),
          );
    }
  }
}
