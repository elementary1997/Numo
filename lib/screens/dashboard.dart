import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../widgets/charts.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction.dart';
import 'backup_actions.dart';
import 'budgets.dart';
import 'categories.dart';
import 'recurring.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final stats = ref.watch(monthStatsProvider(month));
    final balance = ref.watch(balanceProvider);
    final recent = ref.watch(transactionsProvider).take(5).toList();
    final categories = ref.watch(categoriesProvider);
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
              PopupMenuButton<String>(
                tooltip: 'Меню',
                icon: Icon(Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (value) => switch (value) {
                  'categories' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CategoriesScreen())),
                  'budgets' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const BudgetsScreen())),
                  'recurring' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RecurringScreen())),
                  'export' => exportBackup(context, ref),
                  'import' => importBackup(context, ref),
                  _ => null,
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'categories',
                    child: ListTile(
                      leading: Icon(Icons.sell_outlined),
                      title: Text('Категории'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'budgets',
                    child: ListTile(
                      leading: Icon(Icons.track_changes_rounded),
                      title: Text('Бюджеты'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'recurring',
                    child: ListTile(
                      leading: Icon(Icons.autorenew_rounded),
                      title: Text('Регулярные'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.upload_file_rounded),
                      title: Text('Экспорт данных'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.download_rounded),
                      title: Text('Импорт данных'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BalanceCard(balance: balance, stats: stats),
          const SizedBox(height: 12),
          const _SafeToSpendCard(),
          const SizedBox(height: 8),
          if (stats.byCategory.isNotEmpty) ...[
            _SectionHeader(title: 'Структура трат'),
            const SizedBox(height: 12),
            _SpendingBreakdown(stats: stats, categories: categories),
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
            ...recent.map((t) => TransactionTile(
                  tx: t,
                  showTime: false,
                  onTap: () => showAddTransactionSheet(context, initial: t),
                )),
        ],
      ),
    );
  }
}

/// Компактная карточка «безопасно тратить сегодня» с предупреждением
/// о категориях на грани лимита; скрыта, пока бюджеты не настроены.
class _SafeToSpendCard extends ConsumerWidget {
  const _SafeToSpendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeToday = ref.watch(safeToSpendTodayProvider);
    if (safeToday == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final warnings = ref
        .watch(budgetProgressProvider)
        .where((b) => b.nearLimit || b.overspent)
        .toList();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BudgetsScreen())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.today_rounded, color: NumoColors.violet, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Безопасно тратить сегодня',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    Text(
                      formatMoney(safeToday),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (warnings.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (warnings.any((b) => b.overspent)
                            ? NumoColors.coral
                            : NumoColors.amber)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    warnings.any((b) => b.overspent)
                        ? 'Лимит превышен'
                        : 'Близко к лимиту',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: warnings.any((b) => b.overspent)
                          ? NumoColors.coral
                          : NumoColors.amber,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
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
  const _SpendingBreakdown({required this.stats, required this.categories});

  final MonthStats stats;
  final List<TxCategory> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = stats.byCategory.entries.take(5).toList();
    final values = entries.map((e) => e.value).toList();
    final colors =
        entries.map((e) => categories.byId(e.key).color).toList();

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
                        category: categories.byId(e.key),
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
