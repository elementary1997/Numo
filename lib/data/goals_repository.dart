import 'dart:ui' show Color;

import 'package:drift/drift.dart';

import '../models/goal.dart';
import 'database.dart';

/// Хранилище целей; write-through паттерн, как у остальных.
class GoalsRepository {
  GoalsRepository._(this._db, List<Goal> cache) : _cache = cache;

  final NumoDatabase _db;
  List<Goal> _cache;

  static Future<GoalsRepository> open(NumoDatabase db) async {
    final rows = await db.select(db.goalRows).get();
    return GoalsRepository._(db, [
      for (final row in rows)
        Goal(
          id: row.id,
          title: row.title,
          iconKey: row.iconKey,
          color: Color(row.color),
          targetAmount: row.targetAmount,
          savedAmount: row.savedAmount,
          deadline: row.deadline,
        ),
    ]);
  }

  List<Goal> loadAll() => List.unmodifiable(_cache);

  Future<void> saveAll(List<Goal> goals) async {
    _cache = [...goals];
    await _db.transaction(() async {
      await _db.delete(_db.goalRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.goalRows, [
          for (final g in _cache)
            GoalRowsCompanion(
              id: Value(g.id),
              title: Value(g.title),
              iconKey: Value(g.iconKey),
              color: Value(g.color.toARGB32()),
              targetAmount: Value(g.targetAmount),
              savedAmount: Value(g.savedAmount),
              deadline: Value(g.deadline),
            ),
        ]);
      });
    });
  }
}
