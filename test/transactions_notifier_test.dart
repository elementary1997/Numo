import 'dart:ui' show Color;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/account.dart';
import 'package:numo/models/transaction.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Tx tx(String id, double amount, {int day = 1}) => Tx(
      id: id,
      type: TxType.expense,
      amount: amount,
      categoryId: 'groceries',
      date: DateTime(2026, 8, day),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NumoDatabase db;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // Миграция уже «прошла», чтобы демо-данные не мешали тестам.
      'numo.transactions.migrated-to-drift.v1': true,
    });
    db = NumoDatabase(NativeDatabase.memory());
    final repo = await TransactionsRepository.open(db);
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('add вставляет операцию и сохраняет сортировку по дате', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100, day: 5));
    await notifier.add(tx('b', 200, day: 10));
    await notifier.add(tx('c', 300, day: 1));

    final ids = container.read(transactionsProvider).map((t) => t.id).toList();
    expect(ids, ['b', 'a', 'c']);
  });

  test('update заменяет операцию по id и пересортировывает', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100, day: 5));
    await notifier.add(tx('b', 200, day: 10));

    await notifier.update(tx('a', 999, day: 20));

    final txs = container.read(transactionsProvider);
    expect(txs.first.id, 'a');
    expect(txs.first.amount, 999);
    expect(txs.length, 2);
  });

  test('изменения переживают перезагрузку из репозитория', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100));
    await notifier.update(tx('a', 555));

    final reloaded = await TransactionsRepository.open(db);
    expect(reloaded.loadAll().single.amount, 555);
  });

  test('remove удаляет операцию', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100));
    await notifier.remove('a');
    expect(container.read(transactionsProvider), isEmpty);
  });

  test('remove переживает перезагрузку из репозитория', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100));
    await notifier.add(tx('b', 200));
    await notifier.remove('a');

    final reloaded = await TransactionsRepository.open(db);
    expect(reloaded.loadAll().single.id, 'b');
  });

  test('addAll дедуплицирует по id и переживает перезагрузку', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100, day: 3));
    // 'a' приходит повторно с новой суммой — обновляется, не дублируется.
    await notifier.addAll([tx('a', 111, day: 3), tx('b', 200, day: 7)]);

    final ids = container.read(transactionsProvider).map((t) => t.id).toList();
    expect(ids, ['b', 'a']);

    final reloaded = await TransactionsRepository.open(db);
    final byId = {for (final t in reloaded.loadAll()) t.id: t};
    expect(byId.length, 2);
    expect(byId['a']!.amount, 111);
  });

  test('createTransfer создаёт пару системных операций и сохраняет их',
      () async {
    const from = Account(
        id: 'acc-1', title: 'Карта', iconKey: 'card', color: Color(0xFF000000));
    const to = Account(
        id: 'acc-2', title: 'Нал', iconKey: 'cash', color: Color(0xFF000000));
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.createTransfer(
        from: from, to: to, amountFrom: 500, amountTo: 500);

    final txs = container.read(transactionsProvider);
    expect(txs.length, 2);
    expect(txs.every((t) => t.isTransfer), isTrue);
    expect(txs.fold(0.0, (s, t) => s + t.signedAmount), 0);

    final reloaded = await TransactionsRepository.open(db);
    expect(reloaded.loadAll().length, 2);
  });
}
