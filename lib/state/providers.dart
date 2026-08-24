import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/budgets_repository.dart';
import '../data/categories_repository.dart';
import '../data/recurring_repository.dart';
import '../data/repository.dart';
import '../models/category.dart';
import '../models/recurring.dart';
import '../models/transaction.dart';

final repositoryProvider = Provider<TransactionsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class CategoriesNotifier extends Notifier<List<TxCategory>> {
  @override
  List<TxCategory> build() => ref.read(categoriesRepositoryProvider).loadAll();

  Future<void> add(TxCategory category) async {
    state = [...state, category];
    await ref.read(categoriesRepositoryProvider).saveAll(state);
  }

  Future<void> update(TxCategory category) async {
    state = [
      for (final c in state) c.id == category.id ? category : c,
    ];
    await ref.read(categoriesRepositoryProvider).saveAll(state);
  }

  Future<void> setArchived(String id, bool archived) async {
    state = [
      for (final c in state)
        c.id == id ? c.copyWith(archived: archived) : c,
    ];
    await ref.read(categoriesRepositoryProvider).saveAll(state);
  }

  /// Полная замена данных — используется восстановлением из бэкапа.
  Future<void> replaceAll(List<TxCategory> categories) async {
    state = [...categories];
    await ref.read(categoriesRepositoryProvider).saveAll(state);
  }
}

final categoriesProvider =
    NotifierProvider<CategoriesNotifier, List<TxCategory>>(
        CategoriesNotifier.new);

/// Категории, доступные для выбора при добавлении операции.
final activeCategoriesProvider =
    Provider.family<List<TxCategory>, bool>((ref, isIncome) => ref
        .watch(categoriesProvider)
        .where((c) => c.isIncome == isIncome && !c.archived)
        .toList());

class TransactionsNotifier extends Notifier<List<Tx>> {
  @override
  List<Tx> build() => ref.read(repositoryProvider).loadAll();

  Future<void> add(Tx tx) async {
    state = [tx, ...state]..sort((a, b) => b.date.compareTo(a.date));
    await ref.read(repositoryProvider).saveAll(state);
  }

  Future<void> update(Tx tx) async {
    state = [
      for (final t in state) t.id == tx.id ? tx : t,
    ]..sort((a, b) => b.date.compareTo(a.date));
    await ref.read(repositoryProvider).saveAll(state);
  }

  Future<void> remove(String id) async {
    state = state.where((t) => t.id != id).toList();
    await ref.read(repositoryProvider).saveAll(state);
  }

  /// Полная замена данных — используется восстановлением из бэкапа.
  Future<void> replaceAll(List<Tx> transactions) async {
    state = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    await ref.read(repositoryProvider).saveAll(state);
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<Tx>>(TransactionsNotifier.new);

/// Сводка за месяц: доходы, расходы, разбивка по категориям,
/// расходы по дням для графиков.
class MonthStats {
  const MonthStats({
    required this.month,
    required this.income,
    required this.expense,
    required this.byCategory,
    required this.dailyExpense,
  });

  final DateTime month;
  final double income;
  final double expense;

  /// categoryId → сумма расходов, по убыванию.
  final Map<String, double> byCategory;

  /// Расходы по дням месяца, индекс 0 — первое число.
  final List<double> dailyExpense;

  double get net => income - expense;
}

/// Выбранный месяц аналитики (первое число месяца).
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthStatsProvider = Provider.family<MonthStats, DateTime>((ref, month) {
  final txs = ref.watch(transactionsProvider).where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );

  var income = 0.0;
  var expense = 0.0;
  final byCategory = <String, double>{};
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final daily = List<double>.filled(daysInMonth, 0);

  for (final t in txs) {
    if (t.isExpense) {
      expense += t.amount;
      byCategory.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      daily[t.date.day - 1] += t.amount;
    } else {
      income += t.amount;
    }
  }

  final sorted = Map.fromEntries(
    byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );

  return MonthStats(
    month: month,
    income: income,
    expense: expense,
    byCategory: sorted,
    dailyExpense: daily,
  );
});

/// Общий баланс по всем операциям.
final balanceProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .fold(0.0, (sum, t) => sum + t.signedAmount);
});

final budgetsRepositoryProvider = Provider<BudgetsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final recurringRepositoryProvider = Provider<RecurringRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class RecurringNotifier extends Notifier<List<RecurringRule>> {
  @override
  List<RecurringRule> build() =>
      ref.read(recurringRepositoryProvider).loadAll();

  /// Сохраняет правило и сразу материализует наступившие даты,
  /// чтобы операция появилась без перезапуска приложения.
  Future<void> upsert(RecurringRule rule) async {
    final repo = ref.read(recurringRepositoryProvider);
    final exists = state.any((r) => r.id == rule.id);
    await repo.saveAll([
      if (exists)
        for (final r in state) r.id == rule.id ? rule : r
      else ...[
        ...state,
        rule,
      ],
    ]);
    await repo.materialize(ref.read(repositoryProvider));
    state = repo.loadAll();
    ref.invalidate(transactionsProvider);
  }

  Future<void> remove(String id) async {
    final repo = ref.read(recurringRepositoryProvider);
    await repo.saveAll(state.where((r) => r.id != id).toList());
    state = repo.loadAll();
  }
}

final recurringProvider =
    NotifierProvider<RecurringNotifier, List<RecurringRule>>(
        RecurringNotifier.new);

class BudgetsNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() =>
      ref.read(budgetsRepositoryProvider).loadAll();

  Future<void> setLimit(String categoryId, double? limit) async {
    await ref.read(budgetsRepositoryProvider).setLimit(categoryId, limit);
    state = ref.read(budgetsRepositoryProvider).loadAll();
  }
}

final budgetsProvider = NotifierProvider<BudgetsNotifier, Map<String, double>>(
    BudgetsNotifier.new);

/// Прогресс бюджета одной категории в текущем месяце.
class BudgetProgress {
  const BudgetProgress({
    required this.category,
    required this.limit,
    required this.spent,
  });

  final TxCategory category;
  final double limit;
  final double spent;

  double get share => limit <= 0 ? 0 : spent / limit;
  bool get nearLimit => share >= 0.8 && share < 1;
  bool get overspent => share >= 1;
}

/// Бюджеты текущего месяца с прогрессом, по убыванию заполненности.
final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  if (budgets.isEmpty) return const [];
  final now = DateTime.now();
  final stats = ref.watch(monthStatsProvider(DateTime(now.year, now.month)));
  final categories = ref.watch(categoriesProvider);
  final progress = [
    for (final entry in budgets.entries)
      BudgetProgress(
        category: categories.byId(entry.key),
        limit: entry.value,
        spent: stats.byCategory[entry.key] ?? 0,
      ),
  ]..sort((a, b) => b.share.compareTo(a.share));
  return progress;
});

/// «Безопасно тратить сегодня»: остаток суммарного бюджета месяца,
/// поделённый на оставшиеся дни. null — бюджеты не настроены.
final safeToSpendTodayProvider = Provider<double?>((ref) {
  final progress = ref.watch(budgetProgressProvider);
  if (progress.isEmpty) return null;
  final totalLimit = progress.fold(0.0, (sum, b) => sum + b.limit);
  final totalSpent = progress.fold(0.0, (sum, b) => sum + b.spent);
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysLeft = daysInMonth - now.day + 1;
  final remaining = totalLimit - totalSpent;
  return remaining <= 0 ? 0 : remaining / daysLeft;
});
