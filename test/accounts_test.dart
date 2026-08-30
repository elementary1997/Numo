import 'dart:ui' show Color;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/members_repository.dart';
import 'package:numo/data/rates_repository.dart';
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
  late TransactionsRepository txRepo;
  late AccountsRepository accountsRepo;
  late MembersRepository membersRepo;

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
    txRepo = await TransactionsRepository.open(db);
    accountsRepo = await AccountsRepository.open(db);
    await accountsRepo.saveAll([Accounts.main, cash, usd]);
    // Автор операции берётся из справочника участников (ADR-0014).
    membersRepo = await MembersRepository.open(db);
    container = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(txRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
      membersRepositoryProvider.overrideWithValue(membersRepo),
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

  test('статистика месяца сводит валютные суммы в рубли по курсу ЦБ',
      () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(Tx(
      id: 'rub',
      type: TxType.expense,
      amount: 1000,
      categoryId: 'cafe',
      date: DateTime(2026, 8, 3),
      accountId: 'main',
    ));
    await notifier.add(Tx(
      id: 'usd',
      type: TxType.expense,
      amount: 100,
      categoryId: 'cafe',
      date: DateTime(2026, 8, 4),
      accountId: 'usd',
    ));

    // Без курсов суммы остаются по номиналу, но валюта названа честно.
    final offline = container.read(monthStatsProvider(DateTime(2026, 8)));
    expect(offline.expense, 1100);
    expect(offline.unconverted, ['USD']);
    expect(offline.approximate, isFalse);

    final withRates = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(txRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
      membersRepositoryProvider.overrideWithValue(membersRepo),
      ratesProvider.overrideWith((ref) async => RatesSnapshot(
            rates: const {'USD': 90},
            fetchedAt: DateTime.now(),
          )),
    ]);
    addTearDown(withRates.dispose);
    await withRates.read(ratesProvider.future);

    final stats = withRates.read(monthStatsProvider(DateTime(2026, 8)));
    expect(stats.expense, 1000 + 100 * 90);
    expect(stats.byCategory['cafe'], 1000 + 100 * 90);
    expect(stats.dailyExpense[3], 9000); // 4 августа — 100 $
    expect(stats.approximate, isTrue);
    expect(stats.unconverted, isEmpty);
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
