import 'dart:ui' show Color;

import 'package:drift/drift.dart';

import '../models/account.dart';
import 'database.dart';

/// Хранилище счетов; write-through паттерн. На чистой установке
/// сидируется счётом по умолчанию [Accounts.main] — на него же
/// попадают все операции, созданные до появления счетов.
class AccountsRepository {
  AccountsRepository._(this._db, List<Account> cache) : _cache = cache;

  final NumoDatabase _db;
  List<Account> _cache;

  static Future<AccountsRepository> open(NumoDatabase db,
      {String seedLocale = 'ru'}) async {
    final rows = await db.select(db.accountRows).get();
    if (rows.isNotEmpty) {
      return AccountsRepository._(db, rows.map(_fromRow).toList());
    }
    final repo = AccountsRepository._(db, []);
    await repo.saveAll([Accounts.mainFor(seedLocale)]);
    return repo;
  }

  List<Account> loadAll() => List.unmodifiable(_cache);

  Future<void> saveAll(List<Account> accounts) async {
    _cache = [...accounts];
    await _db.transaction(() async {
      await _db.delete(_db.accountRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.accountRows, _cache.map(_toRow));
      });
    });
  }

  static Account _fromRow(AccountRow row) => Account(
        id: row.id,
        title: row.title,
        iconKey: row.iconKey,
        color: Color(row.color),
        currency: row.currency,
        archived: row.archived,
        kind: AccountKind.values.byName(row.kind),
        rate: row.rate,
        openedAt: row.openedAt,
        closesAt: row.closesAt,
      );

  static AccountRowsCompanion _toRow(Account a) => AccountRowsCompanion(
        id: Value(a.id),
        title: Value(a.title),
        iconKey: Value(a.iconKey),
        color: Value(a.color.toARGB32()),
        currency: Value(a.currency),
        archived: Value(a.archived),
        kind: Value(a.kind.name),
        rate: Value(a.rate),
        openedAt: Value(a.openedAt),
        closesAt: Value(a.closesAt),
      );
}
