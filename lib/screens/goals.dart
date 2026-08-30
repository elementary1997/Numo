import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/l10n.dart';
import '../core/dialogs.dart';
import '../core/money.dart';
import '../core/theme.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../state/providers.dart';

/// Цели накоплений: прогресс, срок и нужный месячный темп.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.menuGoals)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showGoalEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.newGoal),
      ),
      body: goals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.l10n.goalsEmptyHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                for (final goal in goals) ...[
                  _GoalCard(goal: goal),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Цель с привязанным счётом живёт от его баланса: пополнили счёт —
    // прогресс обновился сам, ручные пополнения не нужны.
    final linked = goal.accountId != null;
    final effective = linked
        ? goal.copyWith(
            savedAmount: ref.watch(accountBalanceProvider(goal.accountId!)))
        : goal;
    final monthly = effective.monthlyNeeded();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showGoalEditor(context, initial: goal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: goal.color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(goal.icon, color: goal.color, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          context.l10n.savedOfTarget(
                              formatMoney(effective.savedAmount),
                              formatMoney(effective.targetAmount)),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (effective.reached)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: NumoColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.goalReached,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: NumoColors.mint,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else if (!linked)
                    FilledButton.tonal(
                      onPressed: () => _showTopUpDialog(context, ref),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            goal.color.withValues(alpha: 0.14),
                        foregroundColor: goal.color,
                      ),
                      child: Text(context.l10n.topUp,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: effective.progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(
                        effective.reached ? NumoColors.mint : goal.color),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${(effective.progress * 100).round()}%',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  if (goal.deadline != null)
                    Text(
                      monthly != null
                          ? '${DateFormat('d MMM yyyy', context.localeCode).format(goal.deadline!)} · ${context.l10n.perMonthNeeded(formatMoney(monthly))}'
                          : DateFormat('d MMM yyyy', context.localeCode)
                              .format(goal.deadline!),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTopUpDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final accounts = ref.read(activeAccountsProvider);
    final goalAccount =
        goal.accountId == null ? null : accounts.byId(goal.accountId!);
    // Источник по умолчанию — первый счёт, отличный от счёта цели.
    String? sourceId = accounts
        .where((a) => a.id != goal.accountId)
        .map((a) => a.id)
        .firstOrNull;

    final amount = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(goal.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration:
                    InputDecoration(labelText: context.l10n.topUpAmount),
              ),
              // Счёт-источник спрашиваем, когда у цели есть свой счёт:
              // пополнение станет переводом источник → счёт цели.
              if (goalAccount != null && accounts.length > 1) ...[
                const SizedBox(height: 12),
                DropdownMenu<String?>(
                  initialSelection: sourceId,
                  label: Text(context.l10n.topUpFromAccount),
                  expandedInsets: EdgeInsets.zero,
                  onSelected: (v) =>
                      setDialogState(() => sourceId = v),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                        value: null, label: context.l10n.noneOption),
                    for (final a in accounts)
                      if (a.id != goal.accountId)
                        DropdownMenuEntry(value: a.id, label: a.title),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                  double.tryParse(controller.text.replaceAll(',', '.'))),
              child: Text(context.l10n.topUp),
            ),
          ],
        ),
      ),
    );
    disposeAfterDialog(controller);
    if (amount == null || amount <= 0) return;

    await ref.read(goalsProvider.notifier).topUp(goal.id, amount);
    // Деньги реально переезжают между счетами. Суммы цели ведутся в
    // рублях, поэтому валютный счёт получает эквивалент по курсу ЦБ,
    // а не то же число единиц своей валюты.
    if (goalAccount != null && sourceId != null) {
      final source = accounts.byId(sourceId!);
      final convert = ref.read(currencyConvertProvider);
      final amountFrom =
          convert(amount, Currencies.rub, source.currency) ?? amount;
      final amountTo =
          convert(amount, Currencies.rub, goalAccount.currency) ?? amount;
      await ref.read(transactionsProvider.notifier).createTransfer(
            from: source,
            to: goalAccount,
            amountFrom: amountFrom,
            amountTo: amountTo,
          );
    }
  }
}

/// Sheet создания/редактирования цели.
Future<void> showGoalEditor(BuildContext context, {Goal? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (_) => _GoalEditor(initial: initial),
  );
}

class _GoalEditor extends ConsumerStatefulWidget {
  const _GoalEditor({this.initial});

  final Goal? initial;

  @override
  ConsumerState<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<_GoalEditor> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late String _iconKey;
  late Color _color;
  DateTime? _deadline;
  String? _accountId;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final g = widget.initial;
    _title = TextEditingController(text: g?.title ?? '');
    _target = TextEditingController(
        text: g == null
            ? ''
            : g.targetAmount == g.targetAmount.roundToDouble()
                ? g.targetAmount.toStringAsFixed(0)
                : g.targetAmount.toString());
    _iconKey = g?.iconKey ?? 'flag';
    _color = g?.color ?? NumoColors.mint;
    _deadline = g?.deadline;
    _accountId = g?.accountId;
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final target = double.tryParse(_target.text.replaceAll(',', '.'));
    if (title.isEmpty || target == null || target <= 0) return;
    await ref.read(goalsProvider.notifier).upsert(Goal(
          id: widget.initial?.id ??
              'goal-${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          iconKey: _iconKey,
          color: _color,
          targetAmount: target,
          savedAmount: widget.initial?.savedAmount ?? 0,
          deadline: _deadline,
          accountId: _accountId,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const icons = ['flag', 'beach', 'home2', 'car', 'laptop', 'gift',
      'school', 'flight', 'heart', 'savings'];

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing
                        ? context.l10n.editGoal
                        : context.l10n.newGoal,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    tooltip: context.l10n.deleteGoal,
                    icon: Icon(Icons.delete_outline_rounded,
                        color: theme.colorScheme.error),
                    onPressed: () async {
                      await ref
                          .read(goalsProvider.notifier)
                          .remove(widget.initial!.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: context.l10n.nameLabel,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _target,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: context.l10n.targetAmountLabel,
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
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.event_rounded, size: 16),
                  label: Text(
                    _deadline == null
                        ? context.l10n.deadlineLabel
                        : DateFormat('dd.MM.yyyy').format(_deadline!),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          _deadline ?? now.add(const Duration(days: 180)),
                      firstDate: now,
                      lastDate: DateTime(now.year + 20),
                    );
                    if (picked != null) {
                      setState(() => _deadline = picked);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final accounts = ref.watch(activeAccountsProvider);
              if (accounts.isEmpty) return const SizedBox.shrink();
              return DropdownMenu<String?>(
                initialSelection: _accountId,
                label: Text(context.l10n.goalAccountLabel),
                expandedInsets: EdgeInsets.zero,
                onSelected: (v) => setState(() => _accountId = v),
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                      value: null, label: context.l10n.noneOption),
                  for (final a in accounts)
                    DropdownMenuEntry(value: a.id, label: a.title),
                ],
              );
            }),
            const SizedBox(height: 18),
            Text(context.l10n.iconLabel,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in icons)
                  _pickTile(
                    theme: theme,
                    selected: _iconKey == key,
                    color: _color,
                    onTap: () => setState(() => _iconKey = key),
                    child: Icon(
                      CategoryIcons.resolve(key),
                      size: 21,
                      color: _iconKey == key
                          ? _color
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(context.l10n.colorLabel,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in CategoryColors.palette)
                  _pickTile(
                    theme: theme,
                    selected: _color == color,
                    color: color,
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _title.text.trim().isEmpty ||
                        (double.tryParse(
                                    _target.text.replaceAll(',', '.')) ??
                                0) <=
                            0
                    ? null
                    : _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(
                    _isEditing ? context.l10n.save : context.l10n.create),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickTile({
    required ThemeData theme,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color:
          selected ? color.withValues(alpha: 0.16) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? color : Colors.transparent, width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}
