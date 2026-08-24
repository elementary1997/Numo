import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../widgets/charts.dart';
import '../core/l10n.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final stats = ref.watch(monthStatsProvider(month));
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Text(context.l10n.navAnalytics,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => ref
                    .read(selectedMonthProvider.notifier)
                    .state = DateTime(month.year, month.month - 1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    toBeginningOfSentenceCase(
                        DateFormat.yMMMM(context.localeCode).format(month)),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: isCurrentMonth
                    ? null
                    : () => ref
                        .read(selectedMonthProvider.notifier)
                        .state = DateTime(month.year, month.month + 1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: context.l10n.income,
                  value: stats.income,
                  color: NumoColors.mint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: context.l10n.expenses,
                  value: stats.expense,
                  color: NumoColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: stats.net >= 0 ? context.l10n.savedThisMonth : context.l10n.overspendTitle,
            value: stats.net.abs(),
            color: stats.net >= 0 ? NumoColors.sky : NumoColors.amber,
          ),
          const SizedBox(height: 20),
          _DailyExpensesCard(stats: stats),
          const SizedBox(height: 20),
          const _CapitalDynamicsCard(),
          const SizedBox(height: 20),
          if (stats.byCategory.isNotEmpty) ...[
            Text(context.l10n.topCategories,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final e in stats.byCategory.entries)
              _CategoryRow(
                category: categories.byId(e.key),
                value: e.value,
                share: stats.expense > 0 ? e.value / stats.expense : 0,
              ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  context.l10n.noExpensesThisMonth,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// «Расходы по дням» с сеткой значений и выбором дня тапом.
class _DailyExpensesCard extends StatefulWidget {
  const _DailyExpensesCard({required this.stats});

  final MonthStats stats;

  @override
  State<_DailyExpensesCard> createState() => _DailyExpensesCardState();
}

class _DailyExpensesCardState extends State<_DailyExpensesCard> {
  int? _selected;

  @override
  void didUpdateWidget(_DailyExpensesCard old) {
    super.didUpdateWidget(old);
    if (old.stats.month != widget.stats.month) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.stats;
    final daily = stats.dailyExpense;
    final maxV = daily.isEmpty ? 0.0 : daily.reduce((a, b) => a > b ? a : b);
    final shown = _selected ?? (maxV > 0 ? daily.indexOf(maxV) : null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(context.l10n.expensesByDay,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (shown != null)
                  Text(
                    '${DateFormat('d MMMM', context.localeCode).format(DateTime(stats.month.year, stats.month.month, shown + 1))} · ${formatMoney(daily[shown])}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 132,
              child: DailyBars(
                values: daily,
                color: NumoColors.violet,
                selectedIndex: shown,
                onBarTap: (i) => setState(() => _selected = i),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final d in [1, 8, 15, 22, daily.length])
                  Text('$d',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Динамика капитала за последние 90 дней.
class _CapitalDynamicsCard extends ConsumerWidget {
  const _CapitalDynamicsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final series = ref.watch(capitalSeriesProvider(90));
    if (series.length < 2) return const SizedBox.shrink();

    final minV = series.reduce((a, b) => a < b ? a : b);
    final normalized = [for (final v in series) v - minV];
    final trendUp = series.last >= series.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(context.l10n.capital90Days,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(
                  formatSigned((series.last - series.first).abs(),
                      isExpense: !trendUp),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: trendUp ? NumoColors.mint : NumoColors.coral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: Sparkline(
                values: normalized,
                labels: series,
                color: trendUp ? NumoColors.mint : NumoColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label,
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                formatMoney(value),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.value,
    required this.share,
  });

  final TxCategory category;
  final double value;
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category.icon, color: category.color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      formatMoney(value),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: share),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.06),
                      valueColor:
                          AlwaysStoppedAnimation(category.color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
