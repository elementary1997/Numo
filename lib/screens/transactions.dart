import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../models/transaction.dart';
import '../state/providers.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction.dart';

enum _Filter { all, expense, income }

final _filterProvider = StateProvider<_Filter>((ref) => _Filter.all);

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_filterProvider);
    final all = ref.watch(transactionsProvider);
    final txs = switch (filter) {
      _Filter.all => all,
      _Filter.expense => all.where((t) => t.isExpense).toList(),
      _Filter.income => all.where((t) => !t.isExpense).toList(),
    };
    final theme = Theme.of(context);

    // Группировка по дням: список пар (дата, операции дня).
    final groups = <(DateTime, List<Tx>)>[];
    for (final tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (groups.isEmpty || groups.last.$1 != day) {
        groups.add((day, [tx]));
      } else {
        groups.last.$2.add(tx);
      }
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text('Операции',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<_Filter>(
              segments: const [
                ButtonSegment(value: _Filter.all, label: Text('Все')),
                ButtonSegment(value: _Filter.expense, label: Text('Расходы')),
                ButtonSegment(value: _Filter.income, label: Text('Доходы')),
              ],
              selected: {filter},
              onSelectionChanged: (s) =>
                  ref.read(_filterProvider.notifier).state = s.first,
              showSelectedIcon: false,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: txs.isEmpty
                ? Center(
                    child: Text(
                      'Операций нет',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    itemCount: groups.length,
                    itemBuilder: (context, i) {
                      final (day, dayTxs) = groups[i];
                      return _DayGroup(day: day, txs: dayTxs);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DayGroup extends ConsumerWidget {
  const _DayGroup({required this.day, required this.txs});

  final DateTime day;
  final List<Tx> txs;

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Сегодня';
    if (day == today.subtract(const Duration(days: 1))) return 'Вчера';
    return toBeginningOfSentenceCase(DateFormat('d MMMM, EEEE', 'ru').format(day));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dayTotal = txs.fold(0.0, (sum, t) => sum + t.signedAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
          child: Row(
            children: [
              Text(
                _dayLabel(day),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                formatSigned(dayTotal.abs(), isExpense: dayTotal < 0),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        for (final tx in txs)
          Dismissible(
            key: ValueKey(tx.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.delete_rounded,
                  color: theme.colorScheme.error),
            ),
            onDismissed: (_) {
              final removed = tx;
              ref.read(transactionsProvider.notifier).remove(tx.id);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Операция удалена'),
                    action: SnackBarAction(
                      label: 'Вернуть',
                      onPressed: () => ref
                          .read(transactionsProvider.notifier)
                          .add(removed),
                    ),
                  ),
                );
            },
            child: TransactionTile(
              tx: tx,
              onTap: () => showAddTransactionSheet(context, initial: tx),
            ),
          ),
      ],
    );
  }
}
