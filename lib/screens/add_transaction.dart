import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../state/providers.dart';

Future<void> showAddTransactionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _AddTransactionSheet(),
  );
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet();

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  TxType _type = TxType.expense;
  String _raw = '0';
  TxCategory? _category;
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();

  double get _amount => double.tryParse(_raw.replaceAll(',', '.')) ?? 0;

  List<TxCategory> get _categories =>
      _type == TxType.expense ? Categories.expense : Categories.income;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _tap(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (key) {
        case '⌫':
          _raw = _raw.length > 1 ? _raw.substring(0, _raw.length - 1) : '0';
        case ',':
          if (!_raw.contains(',')) _raw += ',';
        default:
          if (_raw.contains(',') && _raw.split(',')[1].length >= 2) return;
          if (_raw.length >= 9) return;
          _raw = _raw == '0' ? key : _raw + key;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day,
            _date.hour, _date.minute);
      });
    }
  }

  Future<void> _save() async {
    final category = _category;
    if (_amount <= 0 || category == null) return;
    await ref.read(transactionsProvider.notifier).add(
          Tx(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            type: _type,
            amount: _amount,
            categoryId: category.id,
            date: _date,
            note: _noteController.text.trim(),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _amount > 0 && _category != null;
    final isToday = DateUtils.isSameDay(_date, DateTime.now());

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
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
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: _raw,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: _type == TxType.expense
                      ? theme.colorScheme.onSurface
                      : NumoColors.mint,
                ),
                children: [
                  TextSpan(
                    text: ' ₽',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final selected = _category?.id == c.id;
                  return ChoiceChip(
                    selected: selected,
                    onSelected: (_) => setState(() => _category = c),
                    avatar: Icon(c.icon,
                        size: 18,
                        color: selected ? Colors.white : c.color),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Заметка',
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
                ),
                const SizedBox(width: 10),
                ActionChip(
                  onPressed: _pickDate,
                  avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(
                    isToday
                        ? 'Сегодня'
                        : DateFormat('d MMM', 'ru').format(_date),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Keypad(onTap: _tap),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: NumoColors.violet,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(_type == TxType.expense
                    ? 'Добавить расход'
                    : 'Добавить доход'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onTap});

  final ValueChanged<String> onTap;

  static const _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    ',', '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.1,
      children: [
        for (final key in _keys)
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(key),
              child: Center(
                child: key == '⌫'
                    ? Icon(Icons.backspace_outlined,
                        size: 22, color: theme.colorScheme.onSurfaceVariant)
                    : Text(
                        key,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
