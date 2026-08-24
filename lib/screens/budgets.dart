import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../core/l10n.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgets = ref.watch(budgetsProvider);
    final progress = ref.watch(budgetProgressProvider);
    final safeToday = ref.watch(safeToSpendTodayProvider);
    final categories = ref
        .watch(categoriesProvider)
        .where((c) => !c.isIncome && !c.archived)
        .toList();
    final withoutBudget =
        categories.where((c) => !budgets.containsKey(c.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.menuBudgets)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (safeToday != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: NumoColors.heroGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.today_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.safeToSpendToday,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    Colors.white.withValues(alpha: 0.75))),
                        Text(
                          formatMoney(safeToday),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (progress.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                context.l10n.budgetsEmptyHint,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else ...[
            Text(context.l10n.withLimit,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            for (final b in progress) _BudgetRow(progress: b),
            const SizedBox(height: 20),
          ],
          if (withoutBudget.isNotEmpty) ...[
            Text(context.l10n.withoutLimit,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            for (final c in withoutBudget)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onTap: () => showBudgetDialog(context, ref, c),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(c.icon, color: c.color, size: 22),
                ),
                title: Text(c.title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                trailing: Icon(Icons.add_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ],
      ),
    );
  }
}

class _BudgetRow extends ConsumerWidget {
  const _BudgetRow({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final b = progress;
    final barColor = b.overspent
        ? NumoColors.coral
        : b.nearLimit
            ? NumoColors.amber
            : b.category.color;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => showBudgetDialog(context, ref, b.category,
          currentLimit: b.limit),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: b.category.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(b.category.icon, color: b.category.color, size: 22),
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
                          b.category.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        context.l10n
                            .spentOf(formatMoney(b.spent), formatMoney(b.limit)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: b.overspent
                              ? NumoColors.coral
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: b.share.clamp(0, 1)),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 7,
                        backgroundColor: theme.colorScheme.onSurface
                            .withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation(barColor),
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

/// Диалог установки/снятия месячного лимита категории.
Future<void> showBudgetDialog(
  BuildContext context,
  WidgetRef ref,
  TxCategory category, {
  double? currentLimit,
}) async {
  final controller = TextEditingController(
    text: currentLimit == null
        ? ''
        : currentLimit == currentLimit.roundToDouble()
            ? currentLimit.toStringAsFixed(0)
            : currentLimit.toString(),
  );

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(category.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: InputDecoration(
          labelText: context.l10n.monthlyLimitLabel,
          hintText: context.l10n.monthlyLimitHint,
        ),
      ),
      actions: [
        if (currentLimit != null)
          TextButton(
            onPressed: () {
              ref.read(budgetsProvider.notifier).setLimit(category.id, null);
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.removeLimit),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final limit =
                double.tryParse(controller.text.replaceAll(',', '.'));
            if (limit != null && limit > 0) {
              ref.read(budgetsProvider.notifier).setLimit(category.id, limit);
            }
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
}
