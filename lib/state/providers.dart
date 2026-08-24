import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository.dart';
import '../models/transaction.dart';

final repositoryProvider = Provider<TransactionsRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

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
