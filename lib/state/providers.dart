import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/accounts_repository.dart';
import '../data/budgets_repository.dart';
import '../data/categories_repository.dart';
import '../data/rates_repository.dart';
import '../data/recurring_repository.dart';
import '../data/repository.dart';
import '../data/backup.dart';
import '../data/rules_repository.dart';
import '../data/security_repository.dart';
import '../data/sync_service.dart';
import '../data/update_service.dart';
import '../models/category_rule.dart';
import '../models/account.dart';
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
/// Системная категория переводов скрыта.
final activeCategoriesProvider =
    Provider.family<List<TxCategory>, bool>((ref, isIncome) => ref
        .watch(categoriesProvider)
        .where((c) =>
            c.isIncome == isIncome &&
            !c.archived &&
            c.id != Categories.transfer.id)
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

  /// Перевод между счетами: пара связанных операций системной
  /// категории `transfer`. Суммы могут отличаться (разные валюты).
  Future<void> createTransfer({
    required Account from,
    required Account to,
    required double amountFrom,
    required double amountTo,
    DateTime? date,
  }) async {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final when = date ?? DateTime.now();
    final note = '${from.title} → ${to.title}';
    await add(Tx(
      id: 'trf-$ts-out',
      type: TxType.expense,
      amount: amountFrom,
      categoryId: Categories.transfer.id,
      date: when,
      accountId: from.id,
      note: note,
    ));
    await add(Tx(
      id: 'trf-$ts-in',
      type: TxType.income,
      amount: amountTo,
      categoryId: Categories.transfer.id,
      date: when,
      accountId: to.id,
      note: note,
    ));
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
    required this.byCategoryIncome,
    required this.dailyExpense,
  });

  final DateTime month;
  final double income;
  final double expense;

  /// categoryId → сумма расходов, по убыванию.
  final Map<String, double> byCategory;

  /// categoryId → сумма доходов, по убыванию.
  final Map<String, double> byCategoryIncome;

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
  final byCategoryIncome = <String, double>{};
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final daily = List<double>.filled(daysInMonth, 0);

  for (final t in txs) {
    if (t.isTransfer) continue; // переводы — не доход и не расход
    if (t.isExpense) {
      expense += t.amount;
      byCategory.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      daily[t.date.day - 1] += t.amount;
    } else {
      income += t.amount;
      byCategoryIncome.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
  }

  Map<String, double> sortDesc(Map<String, double> m) => Map.fromEntries(
      m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

  return MonthStats(
    month: month,
    income: income,
    expense: expense,
    byCategory: sortDesc(byCategory),
    byCategoryIncome: sortDesc(byCategoryIncome),
    dailyExpense: daily,
  );
});

/// Общий баланс по всем операциям.
final balanceProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .fold(0.0, (sum, t) => sum + t.signedAmount);
});

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class AccountsNotifier extends Notifier<List<Account>> {
  @override
  List<Account> build() => ref.read(accountsRepositoryProvider).loadAll();

  Future<void> upsert(Account account) async {
    final exists = state.any((a) => a.id == account.id);
    state = exists
        ? [for (final a in state) a.id == account.id ? account : a]
        : [...state, account];
    await ref.read(accountsRepositoryProvider).saveAll(state);
  }

  Future<void> setArchived(String id, bool archived) async {
    state = [
      for (final a in state)
        a.id == id ? a.copyWith(archived: archived) : a,
    ];
    await ref.read(accountsRepositoryProvider).saveAll(state);
  }

  /// Полная замена данных — используется восстановлением из бэкапа.
  /// Пустой список из старого бэкапа заменяется счётом по умолчанию.
  Future<void> replaceAll(List<Account> accounts) async {
    state = accounts.isEmpty ? [Accounts.main] : [...accounts];
    await ref.read(accountsRepositoryProvider).saveAll(state);
  }
}

final accountsProvider =
    NotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

/// Счета, доступные для выбора при добавлении операции.
final activeAccountsProvider = Provider<List<Account>>((ref) =>
    ref.watch(accountsProvider).where((a) => !a.archived).toList());

/// Баланс одного счёта в его валюте.
final accountBalanceProvider = Provider.family<double, String>(
    (ref, accountId) => ref
        .watch(transactionsProvider)
        .where((t) => t.accountId == accountId)
        .fold(0.0, (sum, t) => sum + t.signedAmount));

final rulesRepositoryProvider = Provider<RulesRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class RulesNotifier extends Notifier<List<CategoryRule>> {
  @override
  List<CategoryRule> build() => ref.read(rulesRepositoryProvider).loadAll();

  Future<void> upsert(CategoryRule rule) async {
    final exists = state.any((r) => r.id == rule.id);
    state = exists
        ? [for (final r in state) r.id == rule.id ? rule : r]
        : [...state, rule];
    await ref.read(rulesRepositoryProvider).saveAll(state);
  }

  Future<void> remove(String id) async {
    state = state.where((r) => r.id != id).toList();
    await ref.read(rulesRepositoryProvider).saveAll(state);
  }

  /// Применяет правила к существующим операциям (кроме переводов).
  /// Возвращает число переклассифицированных операций.
  Future<int> applyToExisting() async {
    final txs = ref.read(transactionsProvider);
    var changed = 0;
    final updated = [
      for (final t in txs)
        if (!t.isTransfer &&
            t.note.isNotEmpty &&
            categorizeByRules(t.note, state) != null &&
            categorizeByRules(t.note, state) != t.categoryId)
          () {
            changed++;
            return t.copyWith(
                categoryId: categorizeByRules(t.note, state));
          }()
        else
          t,
    ];
    if (changed > 0) {
      await ref.read(transactionsProvider.notifier).replaceAll(updated);
    }
    return changed;
  }
}

final rulesProvider = NotifierProvider<RulesNotifier, List<CategoryRule>>(
    RulesNotifier.new);

final securityRepositoryProvider = Provider<SecurityRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

/// Заблокировано ли приложение (true при старте, если задан PIN).
final lockedProvider = StateProvider<bool>(
    (ref) => ref.read(securityRepositoryProvider).hasPin);

/// Пройден ли onboarding первого запуска (значение задаётся в main()).
final onboardedProvider = StateProvider<bool>((ref) => true);

/// Язык интерфейса: null — системный (начальное значение задаёт main()).
final localeOverrideProvider = StateProvider<String?>((ref) => null);

/// Тема: 'light' | 'dark' | null — системная (начальное значение из main()).
final themeOverrideProvider = StateProvider<String?>((ref) => null);

final syncServiceProvider = Provider<SyncService>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

/// Снимок всех данных для бэкапа/синхронизации.
/// Принимает `ref.read` — работает и с [Ref], и с WidgetRef.
BackupData collectBackupData(T Function<T>(ProviderListenable<T>) read) =>
    BackupData(
      transactions: read(transactionsProvider),
      categories: read(categoriesProvider),
      accounts: read(accountsProvider),
      budgets: read(budgetsProvider),
      recurring: read(recurringProvider),
    );

final updateServiceProvider =
    Provider<UpdateService>((ref) => UpdateService());

/// Фоновая суточная проверка обновлений (ADR-0010).
final updateCheckProvider = FutureProvider<UpdateInfo?>(
    (ref) => ref.watch(updateServiceProvider).check());

final ratesRepositoryProvider =
    Provider<RatesRepository>((ref) => RatesRepository());

/// Курсы ЦБ (кэш 24 часа); null — курсов нет и не было.
final ratesProvider = FutureProvider<RatesSnapshot?>(
    (ref) => ref.watch(ratesRepositoryProvider).load());

/// Общий капитал в рублях по активным счетам.
/// [approximate] — в сумме есть конвертация по курсу ЦБ;
/// [unconverted] — валюты, для которых курса не нашлось
/// (их счета в сумму не вошли).
class NetWorth {
  const NetWorth({
    required this.value,
    required this.approximate,
    required this.unconverted,
  });

  final double value;
  final bool approximate;
  final List<String> unconverted;
}

/// Динамика капитала: значение на конец каждого из последних [days]
/// дней (включая сегодня), в рублях по текущим курсам.
final capitalSeriesProvider = Provider.family<List<double>, int>((ref, days) {
  final txs = ref.watch(transactionsProvider);
  final accounts = ref.watch(accountsProvider);
  final rates = ref.watch(ratesProvider).valueOrNull;

  double rateFor(String accountId) {
    final currency = accounts.byId(accountId).currency;
    return currency == 'RUB' ? 1 : (rates?.rubFor(currency) ?? 0);
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(Duration(days: days - 1));

  // Стартовая точка — всё, что было до окна.
  var running = txs
      .where((t) => t.date.isBefore(start))
      .fold(0.0, (sum, t) => sum + t.signedAmount * rateFor(t.accountId));

  final byDay = <DateTime, double>{};
  for (final t in txs) {
    if (t.date.isBefore(start)) continue;
    final day = DateTime(t.date.year, t.date.month, t.date.day);
    byDay.update(
        day, (v) => v + t.signedAmount * rateFor(t.accountId),
        ifAbsent: () => t.signedAmount * rateFor(t.accountId));
  }

  final series = <double>[];
  for (var i = 0; i < days; i++) {
    final day = start.add(Duration(days: i));
    running += byDay[day] ?? 0;
    series.add(running);
  }
  return series;
});

final netWorthProvider = Provider<NetWorth>((ref) {
  final accounts = ref.watch(activeAccountsProvider);
  final rates = ref.watch(ratesProvider).valueOrNull;
  var total = 0.0;
  var approximate = false;
  final unconverted = <String>[];
  for (final account in accounts) {
    final balance = ref.watch(accountBalanceProvider(account.id));
    if (account.isRub) {
      total += balance;
      continue;
    }
    final rate = rates?.rubFor(account.currency);
    if (rate == null) {
      if (balance != 0) unconverted.add(account.currency);
      continue;
    }
    total += balance * rate;
    if (balance != 0) approximate = true;
  }
  return NetWorth(
    value: total,
    approximate: approximate,
    unconverted: unconverted,
  );
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

  /// Полная замена данных — используется восстановлением из бэкапа.
  Future<void> replaceAll(List<RecurringRule> rules) async {
    final repo = ref.read(recurringRepositoryProvider);
    await repo.saveAll(rules);
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

  /// Полная замена данных — используется восстановлением из бэкапа.
  Future<void> replaceAll(Map<String, double> budgets) async {
    await ref.read(budgetsRepositoryProvider).replaceAll(budgets);
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
