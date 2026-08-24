import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../state/providers.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction.dart';
import '../core/l10n.dart';

enum _Filter { all, expense, income }

final _filterProvider = StateProvider<_Filter>((ref) => _Filter.all);
final _searchProvider = StateProvider<String>((ref) => '');
final _rangeProvider = StateProvider<DateTimeRange?>((ref) => null);

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  bool _matches(Tx tx, String query, List<TxCategory> categories) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return tx.note.toLowerCase().contains(q) ||
        categories.byId(tx.categoryId).title.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_filterProvider);
    final query = ref.watch(_searchProvider);
    final range = ref.watch(_rangeProvider);
    final all = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final txs = all.where((t) {
      final byType = switch (filter) {
        _Filter.all => true,
        _Filter.expense => t.isExpense,
        _Filter.income => !t.isExpense,
      };
      final byRange = range == null ||
          (!t.date.isBefore(range.start) &&
              t.date.isBefore(range.end.add(const Duration(days: 1))));
      return byType && byRange && _matches(t, query, categories);
    }).toList();
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
            child: Text(context.l10n.navTransactions,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => ref.read(_searchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: context.l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<_Filter>(
                    segments: [
                      ButtonSegment(
                          value: _Filter.all,
                          label: Text(context.l10n.filterAll)),
                      ButtonSegment(
                          value: _Filter.expense,
                          label: Text(context.l10n.expenses)),
                      ButtonSegment(
                          value: _Filter.income,
                          label: Text(context.l10n.income)),
                    ],
                    selected: {filter},
                    onSelectionChanged: (s) =>
                        ref.read(_filterProvider.notifier).state = s.first,
                    showSelectedIcon: false,
                  ),
                ),
                const SizedBox(width: 8),
                _RangeChip(range: range),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: txs.isEmpty
                ? Center(
                    child: Text(
                      query.isNotEmpty || range != null
                          ? context.l10n.nothingFound
                          : context.l10n.noTransactions,
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

/// Чип фильтра по периоду: открывает выбор диапазона дат,
/// повторный тап по крестику сбрасывает фильтр.
class _RangeChip extends ConsumerWidget {
  const _RangeChip({required this.range});

  final DateTimeRange? range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = range != null;
    final label = active
        ? '${DateFormat('d MMM', context.localeCode).format(range!.start)} — '
            '${DateFormat('d MMM', context.localeCode).format(range!.end)}'
        : context.l10n.period;

    return InputChip(
      avatar: active
          ? null
          : const Icon(Icons.calendar_month_rounded, size: 17),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      selected: active,
      showCheckmark: false,
      onPressed: () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: now,
          initialDateRange: range,
        );
        if (picked != null) {
          ref.read(_rangeProvider.notifier).state = picked;
        }
      },
      onDeleted:
          active ? () => ref.read(_rangeProvider.notifier).state = null : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _DayGroup extends ConsumerWidget {
  const _DayGroup({required this.day, required this.txs});

  final DateTime day;
  final List<Tx> txs;

  String _dayLabel(BuildContext context, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return context.l10n.today;
    if (day == today.subtract(const Duration(days: 1))) return context.l10n.yesterday;
    return toBeginningOfSentenceCase(DateFormat('d MMMM, EEEE', context.localeCode).format(day));
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
                _dayLabel(context, day),
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
                borderRadius: BorderRadius.circular(10),
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
                    content: Text(context.l10n.transactionDeleted),
                    action: SnackBarAction(
                      label: context.l10n.undo,
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
