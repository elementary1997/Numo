import 'package:flutter/material.dart';

import 'add_transaction.dart';
import 'analytics.dart';
import 'dashboard.dart';
import 'transactions.dart';

/// Ширина, начиная с которой включается desktop-раскладка
/// с NavigationRail вместо нижней навигации.
const _wideBreakpoint = 840.0;

/// Максимальная ширина колонки контента на широких экранах —
/// чтобы desktop не выглядел растянутым мобильным интерфейсом.
const _contentMaxWidth = 760.0;

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
  ];

  Widget _content() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        child: IndexedStack(
          key: ValueKey(_index),
          index: _index,
          children: _screens,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () => showAddTransactionSheet(context),
                  child: const Icon(Icons.add_rounded, size: 28),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Обзор'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: Text('Операции'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: Text('Аналитика'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: _content(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _content(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Обзор',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Операции',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Аналитика',
          ),
        ],
      ),
    );
  }
}
