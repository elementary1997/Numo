import 'package:drift/drift.dart';

import '../models/recurring.dart';
import '../models/transaction.dart';
import 'database.dart';
import 'repository.dart';

/// Хранилище правил регулярных операций + материализация:
/// при каждом открытии приложения правила превращаются в реальные
/// операции за все наступившие месяцы. Идемпотентно за счёт
/// детерминированных id (`rec-<rule>-<год>-<месяц>`).
class RecurringRepository {
  RecurringRepository._(this._db, List<RecurringRule> cache)
      : _cache = cache;

  final NumoDatabase _db;
  List<RecurringRule> _cache;

  static Future<RecurringRepository> open(NumoDatabase db) async {
    final rows = await db.select(db.recurringRows).get();
    return RecurringRepository._(db, rows.map(_fromRow).toList());
  }

  List<RecurringRule> loadAll() => List.unmodifiable(_cache);

  Future<void> saveAll(List<RecurringRule> rules) async {
    _cache = [...rules];
    await _db.transaction(() async {
      await _db.delete(_db.recurringRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.recurringRows, _cache.map(_toRow));
      });
    });
  }

  /// Создаёт недостающие операции по всем правилам до сегодняшнего дня
  /// включительно и передвигает `appliedThrough`. Возвращает число
  /// созданных операций. Идемпотентно: уже материализованный период
  /// не трогается, поэтому удалённая пользователем сгенерированная
  /// операция не возрождается.
  Future<int> materialize(TransactionsRepository transactions,
      {DateTime? now}) async {
    final today = now ?? DateTime.now();
    final existing = transactions.loadAll().map((t) => t.id).toSet();
    final created = <Tx>[];
    final updatedRules = <RecurringRule>[];

    for (final rule in _cache) {
      final from = rule.appliedThrough ?? rule.startDate;
      var year = rule.startDate.year;
      var month = rule.startDate.month;
      while (year < today.year ||
          (year == today.year && month <= today.month)) {
        final occurrence = rule.occurrenceIn(year, month);
        final id = rule.txIdFor(year, month);
        final alreadyApplied = rule.appliedThrough != null &&
            !occurrence.isAfter(rule.appliedThrough!);
        if (!occurrence.isAfter(today) &&
            !occurrence.isBefore(from) &&
            !alreadyApplied &&
            !existing.contains(id)) {
          created.add(Tx(
            id: id,
            type: rule.type,
            amount: rule.amount,
            categoryId: rule.categoryId,
            date: occurrence,
            note: rule.note,
          ));
        }
        month++;
        if (month > 12) {
          month = 1;
          year++;
        }
      }
      updatedRules.add(rule.copyWith(appliedThrough: today));
    }

    if (created.isNotEmpty) {
      await transactions.upsertAll(created);
    }
    if (updatedRules.isNotEmpty) {
      await saveAll(updatedRules);
    }
    return created.length;
  }

  static RecurringRule _fromRow(RecurringRow row) => RecurringRule(
        id: row.id,
        type: TxType.values.byName(row.type),
        amount: row.amount,
        categoryId: row.categoryId,
        note: row.note,
        dayOfMonth: row.dayOfMonth,
        startDate: row.startDate,
        appliedThrough: row.appliedThrough,
      );

  static RecurringRowsCompanion _toRow(RecurringRule rule) =>
      RecurringRowsCompanion(
        id: Value(rule.id),
        type: Value(rule.type.name),
        amount: Value(rule.amount),
        categoryId: Value(rule.categoryId),
        note: Value(rule.note),
        dayOfMonth: Value(rule.dayOfMonth),
        startDate: Value(rule.startDate),
        appliedThrough: Value(rule.appliedThrough),
      );
}
