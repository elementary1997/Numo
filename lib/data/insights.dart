import '../l10n/app_localizations.dart';
import '../core/money.dart';
import '../models/category.dart';
import '../models/transaction.dart';

enum InsightTone { good, warn, neutral }

/// Локальный инсайт — вычисляется без сети.
class Insight {
  const Insight({required this.text, required this.tone});

  final String text;
  final InsightTone tone;
}

/// Правила локальной аналитики: сравнение с прошлым месяцем, темп
/// трат, крупнейшие категории и операции, состояние бюджетов.
List<Insight> buildInsights({
  required AppLocalizations l10n,
  required List<Tx> transactions,
  required List<TxCategory> categories,
  required Map<String, double> budgets,
  required DateTime now,
}) {
  final insights = <Insight>[];
  final thisMonth = DateTime(now.year, now.month);
  final prevMonth = DateTime(now.year, now.month - 1);

  Map<String, double> spentBy(DateTime month) {
    final result = <String, double>{};
    for (final t in transactions) {
      if (t.isSystem || !t.isExpense) continue;
      if (t.date.year != month.year || t.date.month != month.month) continue;
      result.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    return result;
  }

  double incomeOf(DateTime month) => transactions
      .where((t) =>
          !t.isSystem &&
          !t.isExpense &&
          t.date.year == month.year &&
          t.date.month == month.month)
      .fold(0.0, (sum, t) => sum + t.amount);

  final current = spentBy(thisMonth);
  final previous = spentBy(prevMonth);
  final expense = current.values.fold(0.0, (a, b) => a + b);
  final income = incomeOf(thisMonth);

  String titleOf(String id) => categories.byId(id).title;

  // Норма сбережений или перерасход.
  if (income > 0) {
    final rate = (income - expense) / income * 100;
    if (rate >= 0) {
      insights.add(Insight(
        text: l10n.insSavingsRate(rate.toStringAsFixed(0)),
        tone: rate >= 20 ? InsightTone.good : InsightTone.neutral,
      ));
    } else {
      insights.add(Insight(
        text: l10n.insOverspend(formatMoney(expense - income)),
        tone: InsightTone.warn,
      ));
    }
  }

  // Крупнейшая категория месяца.
  if (current.isNotEmpty && expense > 0) {
    final top =
        current.entries.reduce((a, b) => a.value >= b.value ? a : b);
    insights.add(Insight(
      text: l10n.insTopCategory(
        titleOf(top.key),
        formatMoney(top.value),
        (top.value / expense * 100).toStringAsFixed(0),
      ),
      tone: InsightTone.neutral,
    ));
  }

  // Самый заметный рост и снижение к прошлому месяцу.
  MapEntry<String, double>? topMover;
  MapEntry<String, double>? topSaver;
  for (final entry in current.entries) {
    final before = previous[entry.key] ?? 0;
    if (before < 500) continue;
    final change = (entry.value - before) / before * 100;
    if (change >= 30 && entry.value - before >= 1000) {
      if (topMover == null || change > topMover.value) {
        topMover = MapEntry(entry.key, change);
      }
    }
  }
  for (final entry in previous.entries) {
    final nowValue = current[entry.key] ?? 0;
    if (entry.value < 1000) continue;
    final change = (entry.value - nowValue) / entry.value * 100;
    if (change >= 30) {
      if (topSaver == null || change > topSaver.value) {
        topSaver = MapEntry(entry.key, change);
      }
    }
  }
  if (topMover != null) {
    insights.add(Insight(
      text: l10n.insCategoryUp(
          titleOf(topMover.key), topMover.value.toStringAsFixed(0)),
      tone: InsightTone.warn,
    ));
  }
  if (topSaver != null) {
    insights.add(Insight(
      text: l10n.insCategoryDown(
          titleOf(topSaver.key), topSaver.value.toStringAsFixed(0)),
      tone: InsightTone.good,
    ));
  }

  // Темп трат и прогноз до конца месяца.
  if (expense > 0 && now.day >= 3) {
    final daily = expense / now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    insights.add(Insight(
      text: l10n.insRunRate(
          formatMoney(daily), formatMoney(daily * daysInMonth)),
      tone: InsightTone.neutral,
    ));
  }

  // Крупнейшая разовая трата.
  Tx? biggest;
  for (final t in transactions) {
    if (t.isSystem || !t.isExpense) continue;
    if (t.date.year != thisMonth.year || t.date.month != thisMonth.month) {
      continue;
    }
    if (biggest == null || t.amount > biggest.amount) biggest = t;
  }
  if (biggest != null && biggest.amount >= 1000) {
    insights.add(Insight(
      text: l10n.insBiggestTx(
        biggest.note.isNotEmpty ? biggest.note : titleOf(biggest.categoryId),
        formatMoney(biggest.amount),
      ),
      tone: InsightTone.neutral,
    ));
  }

  // Бюджеты.
  if (budgets.isNotEmpty) {
    final over = budgets.entries
        .where((b) => (current[b.key] ?? 0) > b.value)
        .length;
    insights.add(over == 0
        ? Insight(text: l10n.insBudgetsOk, tone: InsightTone.good)
        : Insight(
            text: l10n.insBudgetsOver(over), tone: InsightTone.warn));
  }

  return insights;
}
