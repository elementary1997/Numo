import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import 'accounts.dart';
import 'add_transaction.dart';
import 'analytics.dart';
import 'budgets.dart';
import 'categories.dart';
import 'dashboard.dart';
import 'import_csv.dart';
import 'recurring.dart';
import 'rules.dart';
import 'settings.dart';
import 'transactions.dart';

/// Ширина, начиная с которой включается desktop-раскладка
/// с боковой панелью в стиле macOS вместо нижней навигации.
const _wideBreakpoint = 840.0;

/// Максимальная ширина колонки контента на широких экранах.
const _contentMaxWidth = 860.0;

class _Destination {
  const _Destination(this.icon, this.label, this.builder);

  final IconData icon;
  final String Function(BuildContext) label;
  final WidgetBuilder builder;
}

/// Разделы приложения. Первые три — вкладки мобильной навигации,
/// на desktop все разделы живут в боковой панели.
final _destinations = <_Destination>[
  _Destination(Icons.house_rounded, (c) => c.l10n.navOverview,
      (_) => const DashboardScreen()),
  _Destination(Icons.list_alt_rounded, (c) => c.l10n.navTransactions,
      (_) => const TransactionsScreen()),
  _Destination(Icons.bar_chart_rounded, (c) => c.l10n.navAnalytics,
      (_) => const AnalyticsScreen()),
  _Destination(Icons.account_balance_wallet_rounded,
      (c) => c.l10n.menuAccounts, (_) => const AccountsScreen()),
  _Destination(Icons.sell_rounded, (c) => c.l10n.menuCategories,
      (_) => const CategoriesScreen()),
  _Destination(Icons.track_changes_rounded, (c) => c.l10n.menuBudgets,
      (_) => const BudgetsScreen()),
  _Destination(Icons.autorenew_rounded, (c) => c.l10n.menuRecurring,
      (_) => const RecurringScreen()),
  _Destination(Icons.auto_fix_high_rounded, (c) => c.l10n.menuRules,
      (_) => const RulesScreen()),
  _Destination(Icons.table_view_rounded, (c) => c.l10n.menuImportCsv,
      (_) => const ImportCsvScreen()),
  _Destination(Icons.settings_rounded, (c) => c.l10n.menuSettings,
      (_) => const SettingsScreen()),
];

/// Индексы, после которых в сайдбаре рисуется разделитель.
const _sidebarDividersAfter = {2, 8};

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    return isWide ? _buildWide(context) : _buildCompact(context);
  }

  Widget _buildWide(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 216,
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 10),
                    child: Text(
                      'Numo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () => showAddTransactionSheet(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(context.l10n.addTransaction,
                            style: const TextStyle(fontSize: 13)),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              NumoColors.violet.withValues(alpha: 0.12),
                          foregroundColor: NumoColors.violetDeep,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (var i = 0; i < _destinations.length; i++) ...[
                          _SidebarRow(
                            destination: _destinations[i],
                            selected: _index == i,
                            onTap: () => setState(() => _index = i),
                          ),
                          if (_sidebarDividersAfter.contains(i))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Divider(
                                height: 1,
                                thickness: 0.5,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 0.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          Expanded(
            child: ColoredBox(
              color: theme.colorScheme.surface.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: IndexedStack(
                    index: _index,
                    children: [
                      for (final d in _destinations) d.builder(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    // Мобильная раскладка: три главные вкладки + FAB;
    // остальные разделы доступны из меню на «Обзоре».
    final tabIndex = _index.clamp(0, 2);
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: [
          for (final d in _destinations.take(3)) d.builder(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations.take(3))
            NavigationDestination(
              icon: Icon(d.icon),
              label: d.label(context),
            ),
        ],
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected
            ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            child: Row(
              children: [
                Icon(destination.icon, size: 18, color: NumoColors.violet),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    destination.label(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
