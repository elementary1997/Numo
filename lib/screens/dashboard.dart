import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../widgets/account_avatar.dart';
import '../widgets/charts.dart';
import '../widgets/transaction_tile.dart';
import 'accounts.dart';
import 'add_transaction.dart';
import 'backup_actions.dart';
import 'ai_insights.dart';
import 'budgets.dart';
import 'goals.dart';
import 'categories.dart';
import 'import_csv.dart';
import 'recurring.dart';
import 'rules.dart';
import 'settings_sheets.dart';
import '../core/l10n.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final stats = ref.watch(monthStatsProvider(month));
    final netWorth = ref.watch(netWorthProvider);
    final recent = ref.watch(transactionsProvider).take(5).toList();
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Row(
            children: [
              if (MediaQuery.sizeOf(context).width < 840)
                Text('Numo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    )),
              const Spacer(),
              Text(
                toBeginningOfSentenceCase(
                    DateFormat.yMMMM(context.localeCode).format(now)),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (MediaQuery.sizeOf(context).width < 840)
              PopupMenuButton<String>(
                tooltip: context.l10n.menuTooltip,
                icon: Icon(Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (value) => switch (value) {
                  'categories' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CategoriesScreen())),
                  'budgets' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const BudgetsScreen())),
                  'goals' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const GoalsScreen())),
                  'ai' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AiInsightsScreen())),
                  'recurring' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RecurringScreen())),
                  'accounts' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AccountsScreen())),
                  'rules' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RulesScreen())),
                  'import-csv' => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ImportCsvScreen())),
                  'language' => showLanguageDialog(context, ref),
                  'security' => showSecurityDialog(context, ref),
                  'sync' => showSyncDialog(context, ref),
                  'export-csv' => exportCsv(context, ref),
                  'export' => exportBackup(context, ref),
                  'import' => importBackup(context, ref),
                  _ => null,
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'categories',
                    child: ListTile(
                      leading: Icon(Icons.sell_outlined),
                      title: Text(context.l10n.menuCategories),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'budgets',
                    child: ListTile(
                      leading: Icon(Icons.track_changes_rounded),
                      title: Text(context.l10n.menuBudgets),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'goals',
                    child: ListTile(
                      leading: const Icon(Icons.flag_rounded),
                      title: Text(context.l10n.menuGoals),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ai',
                    child: ListTile(
                      leading: const Icon(Icons.auto_awesome_rounded),
                      title: Text(context.l10n.menuAi),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'recurring',
                    child: ListTile(
                      leading: Icon(Icons.autorenew_rounded),
                      title: Text(context.l10n.menuRecurring),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'accounts',
                    child: ListTile(
                      leading: Icon(Icons.account_balance_wallet_outlined),
                      title: Text(context.l10n.menuAccounts),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rules',
                    child: ListTile(
                      leading: Icon(Icons.auto_fix_high_rounded),
                      title: Text(context.l10n.menuRules),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import-csv',
                    child: ListTile(
                      leading: Icon(Icons.table_view_rounded),
                      title: Text(context.l10n.menuImportCsv),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export-csv',
                    child: ListTile(
                      leading: Icon(Icons.grid_on_rounded),
                      title: Text(context.l10n.menuExportCsv),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'language',
                    child: ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(context.l10n.menuLanguage),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'security',
                    child: ListTile(
                      leading: Icon(Icons.lock_outline_rounded),
                      title: Text(context.l10n.menuSecurity),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'sync',
                    child: ListTile(
                      leading: Icon(Icons.cloud_sync_outlined),
                      title: Text(context.l10n.menuSync),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.upload_file_rounded),
                      title: Text(context.l10n.menuBackup),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.download_rounded),
                      title: Text(context.l10n.menuRestore),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BalanceCard(netWorth: netWorth, stats: stats),
          const SizedBox(height: 12),
          const _AccountsStrip(),
          const _SafeToSpendCard(),
          const SizedBox(height: 8),
          if (stats.byCategory.isNotEmpty) ...[
            _SectionHeader(title: context.l10n.spendingStructure),
            const SizedBox(height: 12),
            _SpendingBreakdown(stats: stats, categories: categories),
            const SizedBox(height: 20),
          ],
          _SectionHeader(title: context.l10n.recentTransactions),
          const SizedBox(height: 4),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  context.l10n.emptyAddFirst,
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

/// Горизонтальная лента счетов с балансами; показывается, когда
/// счетов больше одного.
class _AccountsStrip extends ConsumerWidget {
  const _AccountsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(activeAccountsProvider);
    if (accounts.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: accounts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final a = accounts[i];
            final balance = ref.watch(accountBalanceProvider(a.id));
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AccountsScreen())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      AccountAvatar(account: a, size: 38),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${a.title} · ${accountKindLabel(context, a.kind)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            formatMoneyIn(
                                balance, Currencies.symbol(a.currency)),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
        borderRadius: BorderRadius.circular(12),
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
                    Text(context.l10n.safeToSpendToday,
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
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    warnings.any((b) => b.overspent)
                        ? context.l10n.limitExceededChip
                        : context.l10n.nearLimitChip,
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
  const _BalanceCard({required this.netWorth, required this.stats});

  final NetWorth netWorth;
  final MonthStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: NumoColors.heroGradient,
        borderRadius: BorderRadius.circular(14),
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
            netWorth.unconverted.isEmpty
                ? context.l10n.totalBalance
                : context.l10n
                    .totalBalanceExcluding(netWorth.unconverted.join(', ')),
            style: textTheme.bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: netWorth.value),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '${netWorth.approximate ? '≈ ' : ''}${formatMoney(value)}',
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
                icon: Icons.arrow_upward_rounded,
                label: context.l10n.income,
                value: stats.income,
                color: NumoColors.mint,
              ),
              const SizedBox(width: 12),
              _FlowChip(
                icon: Icons.arrow_downward_rounded,
                label: context.l10n.expenses,
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
          borderRadius: BorderRadius.circular(10),
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
                    Text(context.l10n.forMonth,
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
