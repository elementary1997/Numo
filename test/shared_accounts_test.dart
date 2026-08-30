import 'dart:ui' show Color;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/members_repository.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/data/shared_sync.dart';
import 'package:numo/models/account.dart';
import 'package:numo/models/member.dart';
import 'package:numo/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

Tx tx(
  String id, {
  double amount = 100,
  String accountId = 'family',
  DateTime? updatedAt,
  DateTime? deletedAt,
  String? authorId,
}) =>
    Tx(
      id: id,
      type: TxType.expense,
      amount: amount,
      categoryId: 'groceries',
      date: DateTime(2026, 8, 10),
      accountId: accountId,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      authorId: authorId,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NumoDatabase db;

  const family = Account(
    id: 'family',
    title: 'Семейный',
    iconKey: 'card',
    color: Color(0xFF7C5CFF),
    shared: true,
  );
  const personal = Account(
    id: 'personal',
    title: 'Личный',
    iconKey: 'cash',
    color: Color(0xFF3DDC97),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    db = NumoDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('файл обмена', () {
    test('содержит только общие счета и операции по ним', () {
      const me = Member(id: 'me1', name: 'Паша', color: Color(0xFF7C5CFF));
      final raw = SharedSyncService.encode(
        me: me,
        accounts: [family, personal],
        transactions: [
          tx('shared-1'),
          tx('personal-1', accountId: 'personal'),
        ],
      );

      final decoded = SharedSyncService.decode(raw)!;
      expect(decoded.accounts.map((a) => a.id), ['family']);
      expect(decoded.transactions.map((t) => t.id), ['shared-1']);
      expect(decoded.members.single.name, 'Паша');
      // Чужой файл не делает участника «мной».
      expect(decoded.members.single.isMe, isFalse);
    });

    test('надгробия удалённых операций попадают в файл', () {
      const me = Member(id: 'me1', name: 'Паша', color: Color(0xFF7C5CFF));
      final raw = SharedSyncService.encode(
        me: me,
        accounts: [family],
        transactions: [tx('gone', deletedAt: DateTime(2026, 8, 12))],
      );
      final decoded = SharedSyncService.decode(raw)!;
      expect(decoded.transactions.single.isDeleted, isTrue);
    });

    test('чужой JSON отвергается', () {
      expect(SharedSyncService.decode('{"app":"other"}'), isNull);
      expect(SharedSyncService.decode('не json'), isNull);
    });
  });

  group('слияние операций', () {
    test('чужая операция добавляется, своя более свежая — побеждает',
        () async {
      final repo = await TransactionsRepository.open(db, seedDemo: false);
      await repo.upsertAll(touch: false, [
        tx('a', amount: 100, updatedAt: DateTime(2026, 8, 10, 12)),
      ]);

      final applied = await repo.mergeAll([
        // Новая операция от второго участника.
        tx('b', amount: 500, updatedAt: DateTime(2026, 8, 11), authorId: 'her'),
        // Устаревшая правка нашей операции — не должна примениться.
        tx('a', amount: 999, updatedAt: DateTime(2026, 8, 10, 9), authorId: 'her'),
      ]);

      expect(applied, 1);
      final byId = {for (final t in repo.loadAll()) t.id: t};
      expect(byId['a']!.amount, 100);
      expect(byId['b']!.amount, 500);
      expect(byId['b']!.authorId, 'her');
    });

    test('более свежая чужая правка перекрывает локальную', () async {
      final repo = await TransactionsRepository.open(db, seedDemo: false);
      await repo.upsertAll(touch: false, [
        tx('a', amount: 100, updatedAt: DateTime(2026, 8, 10)),
      ]);

      await repo.mergeAll([
        tx('a', amount: 777, updatedAt: DateTime(2026, 8, 12), authorId: 'her'),
      ]);

      expect(repo.loadAll().single.amount, 777);
    });

    test('удаление у второго участника не воскресает', () async {
      final repo = await TransactionsRepository.open(db, seedDemo: false);
      await repo.upsertAll(touch: false, [
        tx('a', updatedAt: DateTime(2026, 8, 10)),
      ]);

      // Второй участник удалил операцию позже.
      await repo.mergeAll([
        tx('a',
            updatedAt: DateTime(2026, 8, 13),
            deletedAt: DateTime(2026, 8, 13),
            authorId: 'her'),
      ]);
      expect(repo.loadAll(), isEmpty);

      // Его же файл со старой живой версией ничего не меняет.
      await repo.mergeAll([tx('a', updatedAt: DateTime(2026, 8, 10))]);
      expect(repo.loadAll(), isEmpty);
      expect(repo.allRows().single.isDeleted, isTrue);
    });
  });

  test('удаление мягкое: строка остаётся надгробием', () async {
    final repo = await TransactionsRepository.open(db, seedDemo: false);
    await repo.upsertAll(touch: false, [tx('a'), tx('b')]);
    await repo.removeById('a');

    expect(repo.loadAll().map((t) => t.id), ['b']);
    expect(repo.allRows(), hasLength(2));

    final reopened = await TransactionsRepository.open(db, seedDemo: false);
    expect(reopened.loadAll().map((t) => t.id), ['b']);
    expect(reopened.allRows().where((t) => t.isDeleted).single.id, 'a');
  });

  test('счета сливаются по времени изменения', () async {
    final repo = await AccountsRepository.open(db);
    await repo.saveAll([
      family.copyWith(title: 'Семейный', updatedAt: DateTime(2026, 8, 1)),
    ]);

    final applied = await repo.mergeAll([
      family.copyWith(title: 'Наш общий', updatedAt: DateTime(2026, 8, 5)),
      personal.copyWith(shared: true, updatedAt: DateTime(2026, 8, 5)),
    ]);

    expect(applied, 2);
    final byId = {for (final a in repo.loadAll()) a.id: a};
    expect(byId['family']!.title, 'Наш общий');
    expect(byId['personal']!.shared, isTrue);

    // Устаревшее переименование от участника игнорируется.
    await repo.mergeAll([
      family.copyWith(title: 'Старое имя', updatedAt: DateTime(2026, 7, 1)),
    ]);
    expect(repo.loadAll().firstWhere((a) => a.id == 'family').title,
        'Наш общий');
  });

  group('участники', () {
    test('при первом открытии заводится «я»', () async {
      final repo = await MembersRepository.open(db, meName: 'Я');
      expect(repo.me, isNotNull);
      expect(repo.me!.name, 'Я');
      expect(repo.me!.id, hasLength(12));

      // Повторное открытие не плодит вторых «меня».
      final reopened = await MembersRepository.open(db);
      expect(reopened.loadAll().where((m) => m.isMe), hasLength(1));
      expect(reopened.me!.id, repo.me!.id);
    });

    test('участник из чужого файла добавляется и переименовывается',
        () async {
      final repo = await MembersRepository.open(db, meName: 'Я');
      const her = Member(id: 'her1', name: 'Аня', color: Color(0xFF3DDC97));

      expect(await repo.mergeAll([her]), 1);
      expect(repo.loadAll().tryById('her1')!.name, 'Аня');

      expect(await repo.mergeAll([her.copyWith(name: 'Анна')]), 1);
      expect(repo.loadAll().tryById('her1')!.name, 'Анна');

      // Повторное слияние без изменений ничего не трогает.
      expect(await repo.mergeAll([her.copyWith(name: 'Анна')]), 0);
    });

    test('чужой файл не переписывает моё имя', () async {
      final repo = await MembersRepository.open(db, meName: 'Я');
      final myId = repo.me!.id;
      await repo.mergeAll([
        Member(id: myId, name: 'Кто-то другой', color: const Color(0xFF000000)),
      ]);
      expect(repo.me!.name, 'Я');
    });
  });
}
