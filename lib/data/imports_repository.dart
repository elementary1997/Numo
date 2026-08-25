import 'package:drift/drift.dart';

import 'database.dart';

/// Запись журнала импортов: файл выписки и результат.
class ImportRecord {
  const ImportRecord({
    required this.id,
    required this.fileName,
    required this.importedAt,
    required this.opsCount,
  });

  final String id;
  final String fileName;
  final DateTime importedAt;

  /// Сколько операций реально добавлено (дубликаты не считаются).
  final int opsCount;
}

/// Журнал импортированных выписок; write-through паттерн,
/// свежие записи первыми.
class ImportsRepository {
  ImportsRepository._(this._db, List<ImportRecord> cache) : _cache = cache;

  final NumoDatabase _db;
  List<ImportRecord> _cache;

  static Future<ImportsRepository> open(NumoDatabase db) async {
    final rows = await db.select(db.importRows).get();
    final cache = rows.map(_fromRow).toList()
      ..sort((a, b) => b.importedAt.compareTo(a.importedAt));
    return ImportsRepository._(db, cache);
  }

  List<ImportRecord> loadAll() => List.unmodifiable(_cache);

  Future<void> add(ImportRecord record) async {
    _cache = [record, ..._cache.where((r) => r.id != record.id)];
    await _db.into(_db.importRows).insertOnConflictUpdate(_toRow(record));
  }

  static ImportRecord _fromRow(ImportRow row) => ImportRecord(
        id: row.id,
        fileName: row.fileName,
        importedAt: row.importedAt,
        opsCount: row.opsCount,
      );

  static ImportRowsCompanion _toRow(ImportRecord r) => ImportRowsCompanion(
        id: Value(r.id),
        fileName: Value(r.fileName),
        importedAt: Value(r.importedAt),
        opsCount: Value(r.opsCount),
      );
}
