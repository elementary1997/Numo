import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/budgets_repository.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/transaction.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('лимиты сохраняются, обновляются и удаляются', () async {
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = await BudgetsRepository.open(db);
    await repo.setLimit('groceries', 25000);
    await repo.setLimit('cafe', 8000);
    await repo.setLimit('groceries', 30000); // обновление

    final reopened = await BudgetsRepository.open(db);
    expect(reopened.loadAll(), {'groceries': 30000.0, 'cafe': 8000.0});

    await reopened.setLimit('cafe', null);
    expect(reopened.loadAll(), {'groceries': 30000.0});
  });

  test('BudgetProgress: пороги предупреждения и превышения', () {
    const category = Categories.groceries;
    const ok = BudgetProgress(category: category, limit: 1000, spent: 500);
    const near = BudgetProgress(category: category, limit: 1000, spent: 850);
    const over = BudgetProgress(category: category, limit: 1000, spent: 1200);

    expect(ok.nearLimit, isFalse);
    expect(ok.overspent, isFalse);
    expect(near.nearLimit, isTrue);
    expect(near.overspent, isFalse);
    expect(over.overspent, isTrue);
    expect(over.share, 1.2);
  });

  test('safeToSpendToday считается из остатка бюджета и оставшихся дней',
      () async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final txRepo = await TransactionsRepository.open(db);
    await txRepo.saveAll([
      Tx(
        id: 's1',
        type: TxType.expense,
        amount: 400,
        categoryId: 'groceries',
        date: DateTime.now(),
      ),
    ]);
    final catRepo = await CategoriesRepository.open(db);
    final budgetRepo = await BudgetsRepository.open(db);
    await budgetRepo.setLimit('groceries', 10400);
    // Статистика месяца сводит суммы к рублю по валюте счёта,
    // поэтому ей нужен репозиторий счетов.
    final accountsRepo = await AccountsRepository.open(db);

    final container = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(txRepo),
      categoriesRepositoryProvider.overrideWithValue(catRepo),
      budgetsRepositoryProvider.overrideWithValue(budgetRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
    ]);
    addTearDown(container.dispose);

    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day + 1;

    expect(container.read(safeToSpendTodayProvider),
        closeTo(10000 / daysLeft, 0.01));

    // Без бюджетов индикатор скрыт.
    await budgetRepo.setLimit('groceries', null);
    container.refresh(budgetsProvider);
    expect(container.read(safeToSpendTodayProvider), isNull);
  });
}
