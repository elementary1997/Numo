import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../models/category.dart';
import '../models/recurring.dart';
import '../models/transaction.dart';
import '../state/providers.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rules = ref.watch(recurringProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Регулярные')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showRecurringEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новое правило'),
      ),
      body: rules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Подписки, аренда, зарплата — операции, которые повторяются '
                  'каждый месяц, могут создаваться сами.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                for (final rule in rules)
                  Dismissible(
                    key: ValueKey(rule.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.delete_rounded,
                          color: theme.colorScheme.error),
                    ),
                    onDismissed: (_) {
                      ref.read(recurringProvider.notifier).remove(rule.id);
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(const SnackBar(
                            content: Text(
                                'Правило удалено. Созданные операции остались.')));
                    },
                    child: _RuleTile(
                      rule: rule,
                      category: categories.byId(rule.categoryId),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule, required this.category});

  final RecurringRule rule;
  final TxCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: () => showRecurringEditor(context, initial: rule),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(category.icon, color: category.color, size: 23),
      ),
      title: Text(
        rule.note.isNotEmpty ? rule.note : category.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'Каждый месяц, ${rule.dayOfMonth}-го числа',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        formatSigned(rule.amount, isExpense: rule.type == TxType.expense),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: rule.type == TxType.expense
              ? theme.colorScheme.onSurface
              : theme.colorScheme.secondary,
        ),
      ),
    );
  }
}

/// Sheet создания/редактирования правила регулярной операции.
Future<void> showRecurringEditor(BuildContext context,
    {RecurringRule? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _RecurringEditor(initial: initial),
  );
}

class _RecurringEditor extends ConsumerStatefulWidget {
  const _RecurringEditor({this.initial});

  final RecurringRule? initial;

  @override
  ConsumerState<_RecurringEditor> createState() => _RecurringEditorState();
}

class _RecurringEditorState extends ConsumerState<_RecurringEditor> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  TxType _type = TxType.expense;
  TxCategory? _category;
  int _day = 1;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _amount = TextEditingController(
      text: r == null
          ? ''
          : r.amount == r.amount.roundToDouble()
              ? r.amount.toStringAsFixed(0)
              : r.amount.toString(),
    );
    _note = TextEditingController(text: r?.note ?? '');
    if (r != null) {
      _type = r.type;
      _category = ref.read(categoriesProvider).byId(r.categoryId);
      _day = r.dayOfMonth;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    final category = _category;
    if (amount == null || amount <= 0 || category == null) return;
    final now = DateTime.now();
    await ref.read(recurringProvider.notifier).upsert(RecurringRule(
          id: widget.initial?.id ?? 'rule-${now.microsecondsSinceEpoch}',
          type: _type,
          amount: amount,
          categoryId: category.id,
          note: _note.text.trim(),
          dayOfMonth: _day,
          startDate:
              widget.initial?.startDate ?? DateTime(now.year, now.month),
          appliedThrough: widget.initial?.appliedThrough,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories =
        ref.watch(activeCategoriesProvider(_type == TxType.income));
    final canSave = _category != null &&
        (double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0) > 0;

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
            Text(
              _isEditing ? 'Изменить правило' : 'Новое правило',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TxType>(
              segments: const [
                ButtonSegment(value: TxType.expense, label: Text('Расход')),
                ButtonSegment(value: TxType.income, label: Text('Доход')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = null;
              }),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Сумма, ₽',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownMenu<int>(
                  initialSelection: _day,
                  label: const Text('День'),
                  width: 120,
                  onSelected: (v) => setState(() => _day = v ?? 1),
                  dropdownMenuEntries: [
                    for (var d = 1; d <= 31; d++)
                      DropdownMenuEntry(value: d, label: '$d-е'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final selected = _category?.id == c.id;
                  return ChoiceChip(
                    selected: selected,
                    onSelected: (_) => setState(() => _category = c),
                    avatar: Icon(c.icon,
                        size: 18, color: selected ? Colors.white : c.color),
                    label: Text(c.title),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                    selectedColor: c.color,
                    backgroundColor:
                        c.color.withValues(alpha: selected ? 1 : 0.10),
                    side: BorderSide.none,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: InputDecoration(
                hintText: 'Название (например, «Аренда»)',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(_isEditing ? 'Сохранить' : 'Создать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
