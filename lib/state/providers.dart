import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/accounts_repository.dart';
import '../data/budgets_repository.dart';
import '../data/categories_repository.dart';
import '../data/goals_repository.dart';
import '../data/imports_repository.dart';
import '../data/rates_repository.dart';
import '../data/recurring_repository.dart';
import '../data/repository.dart';
import '../data/backup.dart';
import '../data/members_repository.dart';
import '../data/rules_repository.dart';
import '../data/security_repository.dart';
import '../data/statement_import.dart' show categorizeByBankCategory;
import '../data/shared_sync.dart';
import '../data/sync_service.dart';
import '../data/update_service.dart';
import '../models/category_rule.dart';
import '../models/goal.dart';
import '../models/member.dart';
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

  /// Категории из файлов участников: добавляются только отсутствующие,
  /// чужой файл не перекрашивает и не переименовывает мои категории.
  Future<int> mergeMissing(List<TxCategory> incoming) async {
    final known = state.map((c) => c.id).toSet();
    final missing = [
      for (final category in incoming)
        if (!known.contains(category.id)) category,
    ];
    if (missing.isEmpty) return 0;
    state = [...state, ...missing];
    await ref.read(categoriesRepositoryProvider).saveAll(state);
    return missing.length;
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
            !Categories.systemIds.contains(c.id))
        .toList());

class TransactionsNotifier extends Notifier<List<Tx>> {
  @override
  List<Tx> build() => ref.read(repositoryProvider).loadAll();

  Future<void> add(Tx tx) => addAll([tx]);

  /// Пакетное добавление/обновление по id (одиночные операции,
  /// переводы, импорт выписок) — точечная запись без перезаписи
  /// всей таблицы.
  Future<void> addAll(List<Tx> txs) async {
    if (txs.isEmpty) return;
    final repo = ref.read(repositoryProvider);
    await repo.upsertAll(txs, authorId: ref.read(myMemberIdProvider));
    // Состояние берём из репозитория: он проставил отметку изменения
    // и автора, нужных слиянию общих счетов (ADR-0014).
    state = repo.loadAll();
  }

  Future<void> update(Tx tx) async {
    if (!state.any((t) => t.id == tx.id)) return;
    final repo = ref.read(repositoryProvider);
    await repo.upsert(tx);
    state = repo.loadAll();
  }

  Future<void> remove(String id) async {
    final repo = ref.read(repositoryProvider);
    await repo.removeById(id);
    state = repo.loadAll();
  }

  /// Слияние операций общих счетов из файлов других участников.
  /// Возвращает число применённых изменений.
  Future<int> mergeAll(List<Tx> incoming) async {
    final repo = ref.read(repositoryProvider);
    final changed = await repo.mergeAll(incoming);
    if (changed > 0) state = repo.loadAll();
    return changed;
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
    await addAll([
      Tx(
        id: 'trf-$ts-out',
        type: TxType.expense,
        amount: amountFrom,
        categoryId: Categories.transfer.id,
        date: when,
        accountId: from.id,
        note: note,
      ),
      Tx(
        id: 'trf-$ts-in',
        type: TxType.income,
        amount: amountTo,
        categoryId: Categories.transfer.id,
        date: when,
        accountId: to.id,
        note: note,
      ),
    ]);
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
    this.approximate = false,
    this.unconverted = const [],
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

  /// В суммах есть пересчёт по курсу ЦБ — цифры приблизительные.
  final bool approximate;

  /// Валюты, для которых курса не нашлось: их операции посчитаны
  /// по номиналу, как если бы это были рубли.
  final List<String> unconverted;

  double get net => income - expense;
}

/// Сумма операции, пересчитанная в рубли: [rateApplied] — в пересчёте
/// участвовал курс ЦБ (цифра приблизительная), [currency] заполнена,
/// если курса для валюты счёта не нашлось и сумма взята по номиналу.
class RubAmount {
  const RubAmount(this.amount, {this.rateApplied = false, this.currency});

  final double amount;
  final bool rateApplied;
  final String? currency;
}

/// Пересчёт суммы операции в рубли по валюте её счёта (ADR-0007).
/// Без курсов (офлайн на первом запуске) суммы остаются как есть —
/// это ровно то поведение, что было до появления мультивалютности.
final rubAmountProvider = Provider<RubAmount Function(Tx)>((ref) {
  final accounts = ref.watch(accountsProvider);
  final rates = ref.watch(ratesProvider).valueOrNull;
  return (tx) {
    final currency = accounts.byId(tx.accountId).currency;
    if (currency == Currencies.rub) return RubAmount(tx.amount);
    final rate = rates?.rubFor(currency);
    if (rate == null) return RubAmount(tx.amount, currency: currency);
    return RubAmount(tx.amount * rate, rateApplied: true);
  };
});

/// Пересчёт суммы между валютами по курсам ЦБ; null — курса не хватает.
final currencyConvertProvider =
    Provider<double? Function(double, String, String)>((ref) {
  final rates = ref.watch(ratesProvider).valueOrNull;
  return (amount, from, to) {
    if (from == to) return amount;
    final fromRate = from == Currencies.rub ? 1.0 : rates?.rubFor(from);
    final toRate = to == Currencies.rub ? 1.0 : rates?.rubFor(to);
    if (fromRate == null || toRate == null || toRate == 0) return null;
    return amount * fromRate / toRate;
  };
});

/// Выбранный месяц аналитики (первое число месяца).
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthStatsProvider = Provider.family<MonthStats, DateTime>((ref, month) {
  final txs = ref.watch(transactionsProvider).where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );

  final toRub = ref.watch(rubAmountProvider);

  var income = 0.0;
  var expense = 0.0;
  final byCategory = <String, double>{};
  final byCategoryIncome = <String, double>{};
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final daily = List<double>.filled(daysInMonth, 0);
  var approximate = false;
  final unconverted = <String>{};

  for (final t in txs) {
    if (t.isSystem) continue; // переводы/корректировки — вне статистики
    final converted = toRub(t);
    if (converted.rateApplied) approximate = true;
    if (converted.currency != null) unconverted.add(converted.currency!);
    final amount = converted.amount;
    if (t.isExpense) {
      expense += amount;
      byCategory.update(t.categoryId, (v) => v + amount,
          ifAbsent: () => amount);
      daily[t.date.day - 1] += amount;
    } else {
      income += amount;
      byCategoryIncome.update(t.categoryId, (v) => v + amount,
          ifAbsent: () => amount);
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
    approximate: approximate,
    unconverted: unconverted.toList()..sort(),
  );
});

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class AccountsNotifier extends Notifier<List<Account>> {
  @override
  List<Account> build() => ref.read(accountsRepositoryProvider).loadAll();

  Future<void> upsert(Account account) async {
    final stamped = account.copyWith(updatedAt: DateTime.now());
    final exists = state.any((a) => a.id == stamped.id);
    state = exists
        ? [for (final a in state) a.id == stamped.id ? stamped : a]
        : [...state, stamped];
    await ref.read(accountsRepositoryProvider).saveAll(state);
  }

  Future<void> setArchived(String id, bool archived) async {
    final now = DateTime.now();
    state = [
      for (final a in state)
        a.id == id ? a.copyWith(archived: archived, updatedAt: now) : a,
    ];
    await ref.read(accountsRepositoryProvider).saveAll(state);
  }

  /// Слияние общих счетов из файлов других участников (ADR-0014).
  Future<int> mergeAll(List<Account> incoming) async {
    final repo = ref.read(accountsRepositoryProvider);
    final changed = await repo.mergeAll(incoming);
    if (changed > 0) state = repo.loadAll();
    return changed;
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

final importsRepositoryProvider = Provider<ImportsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class ImportsNotifier extends Notifier<List<ImportRecord>> {
  @override
  List<ImportRecord> build() => ref.read(importsRepositoryProvider).loadAll();

  /// Записывает успешный импорт в журнал.
  Future<void> record({
    required String fileName,
    required int opsCount,
  }) async {
    final repo = ref.read(importsRepositoryProvider);
    await repo.add(ImportRecord(
      id: 'impfile-${DateTime.now().microsecondsSinceEpoch}',
      fileName: fileName,
      importedAt: DateTime.now(),
      opsCount: opsCount,
    ));
    state = repo.loadAll();
  }
}

final importsProvider =
    NotifierProvider<ImportsNotifier, List<ImportRecord>>(ImportsNotifier.new);

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

  /// Полная замена данных — используется сбросом и бэкапом.
  Future<void> replaceAll(List<CategoryRule> rules) async {
    state = [...rules];
    await ref.read(rulesRepositoryProvider).saveAll(state);
  }

  /// Применяет правила к существующим операциям (кроме переводов);
  /// операции из «Прочего» дополнительно распределяются по
  /// банковским рубрикам из описания (импорт выписок).
  /// Возвращает число переклассифицированных операций.
  Future<int> applyToExisting() async {
    final txs = ref.read(transactionsProvider);
    var changed = 0;
    final updated = <Tx>[];
    for (final t in txs) {
      String? matched;
      if (!t.isTransfer && t.note.isNotEmpty) {
        matched = categorizeByRules(t.note, state);
        // Банковская рубрика — только фолбэк для неразобранного:
        // вручную выбранные категории не трогаем.
        if (matched == null && t.categoryId == Categories.other.id) {
          matched = categorizeByBankCategory(t.note);
        }
      }
      if (matched != null && matched != t.categoryId) {
        changed++;
        updated.add(t.copyWith(categoryId: matched));
      } else {
        updated.add(t);
      }
    }
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

/// Акцентный цвет (ARGB); null — фирменный фиолетовый.
final accentColorProvider = StateProvider<int?>((ref) => null);

/// Масштаб интерфейса (1.0 — стандартный), начальное значение из main().
final uiScaleProvider = StateProvider<double>((ref) => 1.0);

final membersRepositoryProvider = Provider<MembersRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class MembersNotifier extends Notifier<List<Member>> {
  @override
  List<Member> build() => ref.read(membersRepositoryProvider).loadAll();

  /// Добавляет или переименовывает участника общего счёта.
  Future<void> upsert(Member member) async {
    final repo = ref.read(membersRepositoryProvider);
    await repo.upsert(member);
    state = repo.loadAll();
  }

  Future<void> remove(String id) async {
    final repo = ref.read(membersRepositoryProvider);
    await repo.remove(id);
    state = repo.loadAll();
  }

  /// Участники из чужих файлов обмена.
  Future<int> mergeAll(Iterable<Member> incoming) async {
    final repo = ref.read(membersRepositoryProvider);
    final changed = await repo.mergeAll(incoming);
    if (changed > 0) state = repo.loadAll();
    return changed;
  }
}

final membersProvider =
    NotifierProvider<MembersNotifier, List<Member>>(MembersNotifier.new);

/// Владелец этого устройства — автор создаваемых здесь операций.
final myMemberProvider =
    Provider<Member?>((ref) => ref.watch(membersProvider).me);

final myMemberIdProvider =
    Provider<String?>((ref) => ref.watch(myMemberProvider)?.id);

/// Участники, кроме меня, — люди, с которыми ведутся общие счета.
final otherMembersProvider = Provider<List<Member>>((ref) =>
    ref.watch(membersProvider).where((m) => !m.isMe).toList());

/// Есть ли хотя бы один общий счёт.
final hasSharedAccountsProvider = Provider<bool>(
    (ref) => ref.watch(accountsProvider).any((a) => a.shared));

final sharedSyncProvider = Provider<SharedSyncService>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

/// Снимок общих счетов для публикации в общую папку (ADR-0014):
/// я, счета с флагом «общий» и все операции по ним, включая надгробия
/// удалённых — иначе удаление не доедет до второго участника.
({
  Member me,
  List<Account> accounts,
  List<Tx> transactions,
  List<TxCategory> categories
})? collectSharedData(T Function<T>(ProviderListenable<T>) read,
    TransactionsRepository repository) {
  final me = read(myMemberProvider);
  if (me == null) return null;
  return (
    me: me,
    accounts: read(accountsProvider),
    transactions: repository.allRows(),
    categories: read(categoriesProvider),
  );
}

/// Снимок всех данных для бэкапа/синхронизации.
/// Принимает `ref.read` — работает и с [Ref], и с WidgetRef.
BackupData collectBackupData(T Function<T>(ProviderListenable<T>) read) =>
    BackupData(
      transactions: read(transactionsProvider),
      categories: read(categoriesProvider),
      accounts: read(accountsProvider),
      budgets: read(budgetsProvider),
      recurring: read(recurringProvider),
      goals: read(goalsProvider),
    );

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

class GoalsNotifier extends Notifier<List<Goal>> {
  @override
  List<Goal> build() => ref.read(goalsRepositoryProvider).loadAll();

  Future<void> upsert(Goal goal) async {
    final exists = state.any((g) => g.id == goal.id);
    state = exists
        ? [for (final g in state) g.id == goal.id ? goal : g]
        : [...state, goal];
    await ref.read(goalsRepositoryProvider).saveAll(state);
  }

  Future<void> topUp(String id, double amount) async {
    state = [
      for (final g in state)
        g.id == id ? g.copyWith(savedAmount: g.savedAmount + amount) : g,
    ];
    await ref.read(goalsRepositoryProvider).saveAll(state);
  }

  Future<void> remove(String id) async {
    state = state.where((g) => g.id != id).toList();
    await ref.read(goalsRepositoryProvider).saveAll(state);
  }

  /// Полная замена данных — используется восстановлением из бэкапа.
  Future<void> replaceAll(List<Goal> goals) async {
    state = [...goals];
    await ref.read(goalsRepositoryProvider).saveAll(state);
  }
}

final goalsProvider =
    NotifierProvider<GoalsNotifier, List<Goal>>(GoalsNotifier.new);

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
