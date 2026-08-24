import 'dart:ui' show Color;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/account.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/transaction.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NumoDatabase db;
  late ProviderContainer container;

  const cash = Account(
    id: 'cash',
    title: 'Наличные',
    iconKey: 'cash',
    color: Color(0xFF3DDC97),
  );
  const usd = Account(
    id: 'usd',
    title: 'Долларовый',
    iconKey: 'savings',
    color: Color(0xFF4CC9F0),
    currency: 'USD',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    db = NumoDatabase(NativeDatabase.memory());
    final txRepo = await TransactionsRepository.open(db);
    final accountsRepo = await AccountsRepository.open(db);
    await accountsRepo.saveAll([Accounts.main, cash, usd]);
    container = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(txRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('чистая установка сидируется счётом по умолчанию', () async {
    final freshDb = NumoDatabase(NativeDatabase.memory());
    addTearDown(freshDb.close);
    final repo = await AccountsRepository.open(freshDb);
    expect(repo.loadAll().single.id, Accounts.main.id);
  });

  test('балансы считаются по счетам раздельно', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(Tx(
      id: '1',
      type: TxType.income,
      amount: 1000,
      categoryId: 'salary',
      date: DateTime(2026, 8, 1),
      accountId: 'main',
    ));
    await notifier.add(Tx(
      id: '2',
      type: TxType.expense,
      amount: 300,
      categoryId: 'cafe',
      date: DateTime(2026, 8, 2),
      accountId: 'cash',
    ));

    expect(container.read(accountBalanceProvider('main')), 1000);
    expect(container.read(accountBalanceProvider('cash')), -300);
  });

  test('перевод двигает деньги между счетами и не попадает в статистику',
      () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.createTransfer(
      from: Accounts.main,
      to: cash,
      amountFrom: 500,
      amountTo: 500,
      date: DateTime(2026, 8, 10),
    );

    expect(container.read(accountBalanceProvider('main')), -500);
    expect(container.read(accountBalanceProvider('cash')), 500);

    final stats =
        container.read(monthStatsProvider(DateTime(2026, 8)));
    expect(stats.expense, 0);
    expect(stats.income, 0);
    expect(stats.byCategory, isEmpty);
  });

  test('кросс-валютный перевод сохраняет обе суммы', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.createTransfer(
      from: Accounts.main,
      to: usd,
      amountFrom: 900,
      amountTo: 10,
      date: DateTime(2026, 8, 10),
    );

    expect(container.read(accountBalanceProvider('main')), -900);
    expect(container.read(accountBalanceProvider('usd')), 10);
  });

  test('категория переводов скрыта из выбора операций', () async {
    final freshDb = NumoDatabase(NativeDatabase.memory());
    addTearDown(freshDb.close);
    final categoriesRepo = await CategoriesRepository.open(freshDb);
    final c = ProviderContainer(overrides: [
      categoriesRepositoryProvider.overrideWithValue(categoriesRepo),
    ]);
    addTearDown(c.dispose);

    expect(c.read(categoriesProvider).byId('transfer').title, 'Перевод');
    final selectable = c
        .read(activeCategoriesProvider(false))
        .map((cat) => cat.id);
    expect(selectable, isNot(contains('transfer')));
  });
}
