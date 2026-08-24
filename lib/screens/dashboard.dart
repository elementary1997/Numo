import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../widgets/charts.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final stats = ref.watch(monthStatsProvider(month));
    final balance = ref.watch(balanceProvider);
    final recent = ref.watch(transactionsProvider).take(5).toList();
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Row(
            children: [
              Text('Numo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  )),
              const Spacer(),
              Text(
                toBeginningOfSentenceCase(
                    DateFormat.yMMMM('ru').format(now)),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BalanceCard(balance: balance, stats: stats),
          const SizedBox(height: 20),
          if (stats.byCategory.isNotEmpty) ...[
            _SectionHeader(title: 'Структура трат'),
            const SizedBox(height: 12),
            _SpendingBreakdown(stats: stats),
            const SizedBox(height: 20),
          ],
          _SectionHeader(title: 'Последние операции'),
          const SizedBox(height: 4),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Пока пусто — добавьте первую операцию',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...recent.map((t) => TransactionTile(tx: t, showTime: false)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.stats});

  final double balance;
  final MonthStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: NumoColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: NumoColors.violetDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Общий баланс',
            style: textTheme.bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: balance),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              formatMoney(value),
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _FlowChip(
                icon: Icons.arrow_downward_rounded,
                label: 'Доходы',
                value: stats.income,
                color: NumoColors.mint,
              ),
              const SizedBox(width: 12),
              _FlowChip(
                icon: Icons.arrow_upward_rounded,
                label: 'Расходы',
                value: stats.expense,
                color: NumoColors.coral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7))),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatMoney(value),
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingBreakdown extends StatelessWidget {
  const _SpendingBreakdown({required this.stats});

  final MonthStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = stats.byCategory.entries.take(5).toList();
    final values = entries.map((e) => e.value).toList();
    final colors =
        entries.map((e) => Categories.byId(e.key).color).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: DonutChart(
                values: values,
                colors: colors,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('За месяц',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    FittedBox(
                      child: Text(
                        formatMoney(stats.expense),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _LegendRow(
                        category: Categories.byId(e.key),
                        value: e.value,
                        share: stats.expense > 0 ? e.value / stats.expense : 0,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
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
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: category.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            category.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(share * 100).round()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
