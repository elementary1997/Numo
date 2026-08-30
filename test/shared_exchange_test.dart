import 'dart:io';
import 'dart:ui' show Color;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/data/shared_sync.dart';
import 'package:numo/models/account.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/member.dart';
import 'package:numo/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сквозная проверка обмена через папку (ADR-0013): два устройства,
/// одна папка, настоящие файлы на диске.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const family = Account(
    id: 'family',
    title: 'Семейный',
    iconKey: 'card',
    color: Color(0xFF7C5CFF),
    shared: true,
  );
  const pasha = Member(id: 'pasha', name: 'Паша', color: Color(0xFF7C5CFF));
  const anya = Member(id: 'anya', name: 'Аня', color: Color(0xFF3DDC97));

  late Directory folder;
  late NumoDatabase dbA;
  late NumoDatabase dbB;
  late TransactionsRepository repoA;
  late TransactionsRepository repoB;
  late SharedSyncService sync;

  Tx expense(String id, double amount, {String? authorId, DateTime? at}) => Tx(
        id: id,
        type: TxType.expense,
        amount: amount,
        categoryId: 'groceries',
        date: DateTime(2026, 8, 15),
        accountId: 'family',
        authorId: authorId,
        updatedAt: at,
      );

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('numo-shared');
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
      'numo.shared.dir': folder.path,
    });
    dbA = NumoDatabase(NativeDatabase.memory());
    dbB = NumoDatabase(NativeDatabase.memory());
    repoA = await TransactionsRepository.open(dbA, seedDemo: false);
    repoB = await TransactionsRepository.open(dbB, seedDemo: false);
    sync = await SharedSyncService.open();
  });

  tearDown(() async {
    await dbA.close();
    await dbB.close();
    await folder.delete(recursive: true);
  });

  test('операции ходят между участниками в обе стороны', () async {
    // Паша записал покупку и выложил свой файл.
    await repoA.insertAll([expense('a1', 700, authorId: pasha.id)]);
    await sync.publish(
      me: pasha,
      accounts: [family],
      transactions: repoA.allRows(),
    );

    // Аня забирает чужие файлы — свой собственный не читает.
    final forAnya = await sync.pull(myMemberId: anya.id);
    expect(forAnya.accounts.single.id, 'family');
    expect(await repoB.mergeAll(forAnya.transactions), 1);
    expect(repoB.loadAll().single.amount, 700);

    // Аня добавила свою операцию и выложила файл.
    await repoB.insertAll([expense('b1', 250, authorId: anya.id)]);
    await sync.publish(
      me: anya,
      accounts: [family],
      transactions: repoB.allRows(),
    );

    // У Паши теперь обе операции, и авторство сохранилось.
    final forPasha = await sync.pull(myMemberId: pasha.id);
    await repoA.mergeAll(forPasha.transactions);
    final byId = {for (final t in repoA.loadAll()) t.id: t};
    expect(byId.keys, containsAll(['a1', 'b1']));
    expect(byId['b1']!.authorId, anya.id);

    // В папке ровно по файлу на участника.
    final files = folder
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toList()
      ..sort();
    expect(files, ['numo-shared-anya.json', 'numo-shared-pasha.json']);
  });

  test('удаление у одного участника доезжает до второго', () async {
    await repoA.insertAll([expense('a1', 700, authorId: pasha.id)]);
    await sync.publish(
        me: pasha, accounts: [family], transactions: repoA.allRows());
    await repoB
        .mergeAll((await sync.pull(myMemberId: anya.id)).transactions);
    expect(repoB.loadAll(), hasLength(1));

    // Аня удаляет общую операцию и публикует надгробие.
    await repoB.deleteOne('a1');
    await sync.publish(
        me: anya, accounts: [family], transactions: repoB.allRows());

    // У Паши операция исчезает, хотя его собственная копия была живой.
    await repoA
        .mergeAll((await sync.pull(myMemberId: pasha.id)).transactions);
    expect(repoA.loadAll(), isEmpty);
    expect(repoA.allRows().single.isDeleted, isTrue);
  });

  test('нестандартная категория едет вместе с операцией', () async {
    const hobby = TxCategory(
      id: 'hobby',
      title: 'Хобби',
      iconKey: 'gift',
      color: Color(0xFFF072B6),
    );
    await repoA.insertAll([
      Tx(
        id: 'a1',
        type: TxType.expense,
        amount: 1200,
        categoryId: hobby.id,
        date: DateTime(2026, 8, 15),
        accountId: 'family',
        authorId: pasha.id,
      ),
    ]);
    await sync.publish(
      me: pasha,
      accounts: [family],
      transactions: repoA.allRows(),
      categories: [hobby, Categories.groceries],
    );

    final forAnya = await sync.pull(myMemberId: anya.id);
    // Едут только категории, встречающиеся в общих операциях.
    expect(forAnya.categories.map((c) => c.id), ['hobby']);
    expect(forAnya.categories.single.title, 'Хобби');
  });

  test('личные операции второму участнику не видны', () async {
    const personal = Account(
      id: 'personal',
      title: 'Личный',
      iconKey: 'cash',
      color: Color(0xFF3DDC97),
    );
    await repoA.insertAll([
      expense('shared', 700, authorId: pasha.id),
      Tx(
        id: 'secret',
        type: TxType.expense,
        amount: 5000,
        categoryId: 'shopping',
        date: DateTime(2026, 8, 15),
        accountId: 'personal',
        authorId: pasha.id,
      ),
    ]);
    await sync.publish(
      me: pasha,
      accounts: [family, personal],
      transactions: repoA.allRows(),
    );

    final forAnya = await sync.pull(myMemberId: anya.id);
    expect(forAnya.transactions.map((t) => t.id), ['shared']);
    expect(forAnya.accounts.map((a) => a.id), ['family']);
  });
}
