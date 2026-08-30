import 'dart:math';
import 'dart:ui' show Color;

import 'package:drift/drift.dart';

import '../core/theme.dart';
import '../models/member.dart';
import 'database.dart';

/// Справочник участников общих счетов (ADR-0013). При первом открытии
/// заводит запись «я» со случайным идентификатором — он же попадает
/// в имя файла обмена и в поле автора операций.
class MembersRepository {
  MembersRepository._(this._db, List<Member> cache) : _cache = cache;

  final NumoDatabase _db;
  List<Member> _cache;

  static Future<MembersRepository> open(NumoDatabase db,
      {String meName = 'Я'}) async {
    final rows = await db.select(db.memberRows).get();
    final repo = MembersRepository._(db, rows.map(_fromRow).toList());
    if (repo._cache.every((m) => !m.isMe)) {
      await repo.upsert(Member(
        id: newMemberId(),
        name: meName,
        color: NumoColors.violet,
        isMe: true,
      ));
    }
    return repo;
  }

  /// Случайный идентификатор участника: попадает в имя файла обмена,
  /// поэтому только буквы и цифры.
  static String newMemberId() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random.secure();
    return List.generate(12, (_) => alphabet[rng.nextInt(alphabet.length)])
        .join();
  }

  List<Member> loadAll() => List.unmodifiable(_cache);

  Member? get me => _cache.me;

  Future<void> upsert(Member member) async {
    final exists = _cache.any((m) => m.id == member.id);
    _cache = exists
        ? [for (final m in _cache) m.id == member.id ? member : m]
        : [..._cache, member];
    await _db.into(_db.memberRows).insertOnConflictUpdate(_toRow(member));
  }

  Future<void> remove(String id) async {
    _cache = _cache.where((m) => m.id != id).toList();
    await (_db.delete(_db.memberRows)..where((row) => row.id.equals(id)))
        .go();
  }

  /// Участники из чужих файлов: добавляются, если ещё не знакомы.
  /// Имя уже известного участника обновляется — человек мог его сменить.
  Future<int> mergeAll(Iterable<Member> incoming) async {
    var changed = 0;
    for (final member in incoming) {
      final known = _cache.tryById(member.id);
      if (known == null) {
        await upsert(member);
        changed++;
      } else if (!known.isMe && known.name != member.name) {
        await upsert(known.copyWith(name: member.name));
        changed++;
      }
    }
    return changed;
  }

  static Member _fromRow(MemberRow row) => Member(
        id: row.id,
        name: row.name,
        color: Color(row.color),
        isMe: row.isMe,
      );

  static MemberRowsCompanion _toRow(Member m) => MemberRowsCompanion(
        id: Value(m.id),
        name: Value(m.name),
        color: Value(m.color.toARGB32()),
        isMe: Value(m.isMe),
      );
}
