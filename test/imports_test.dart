import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/imports_repository.dart';

void main() {
  test('журнал импортов сохраняется и отдаётся свежими вперёд', () async {
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = await ImportsRepository.open(db);
    await repo.add(ImportRecord(
      id: 'a',
      fileName: 'statement-july.pdf',
      importedAt: DateTime(2026, 7, 1, 10),
      opsCount: 63,
    ));
    await repo.add(ImportRecord(
      id: 'b',
      fileName: 'statement-august.pdf',
      importedAt: DateTime(2026, 8, 1, 10),
      opsCount: 12,
    ));

    expect(repo.loadAll().map((r) => r.id), ['b', 'a']);

    final reloaded = await ImportsRepository.open(db);
    final records = reloaded.loadAll();
    expect(records.length, 2);
    expect(records.first.fileName, 'statement-august.pdf');
    expect(records.first.opsCount, 12);
  });
}
