import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../state/providers.dart';
import 'categories.dart';
import '../core/l10n.dart';

/// Открывает sheet добавления новой операции, либо редактирования
/// существующей, если передан [initial].
Future<void> showAddTransactionSheet(BuildContext context, {Tx? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (_) => _AddTransactionSheet(initial: initial),
  );
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet({this.initial});

  final Tx? initial;

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  TxType _type = TxType.expense;
  String _raw = '0';
  TxCategory? _category;
  DateTime _date = DateTime.now();
  late String _accountId;

  /// Валюта ввода; null — валюта выбранного счёта.
  String? _currencyOverride;
  final _noteController = TextEditingController();

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.initial;
    final accounts = ref.read(activeAccountsProvider);
    _accountId = tx?.accountId ??
        (accounts.isNotEmpty ? accounts.first.id : Accounts.main.id);
    if (tx != null) {
      _type = tx.type;
      _raw = tx.amount == tx.amount.roundToDouble()
          ? tx.amount.toStringAsFixed(0)
          : tx.amount.toStringAsFixed(2).replaceAll('.', ',');
      _category = ref.read(categoriesProvider).byId(tx.categoryId);
      _date = tx.date;
      _noteController.text = tx.note;
    }
  }

  double get _amount => double.tryParse(_raw.replaceAll(',', '.')) ?? 0;

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

  Future<void> _pickCurrency() async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.currencyLabel),
        children: [
          for (final c in Currencies.supported)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(c),
              child: Text('$c ${Currencies.symbol(c)}'),
            ),
        ],
      ),
    );
    if (chosen != null) setState(() => _currencyOverride = chosen);
  }

  Future<void> _save() async {
    final category = _category;
    if (_amount <= 0 || category == null) return;

    // Ввод в чужой валюте конвертируется в валюту счёта по курсу ЦБ.
    final accountCurrency =
        ref.read(accountsProvider).byId(_accountId).currency;
    final inputCurrency = _currencyOverride ?? accountCurrency;
    var amount = _amount;
    var note = _noteController.text.trim();
    if (inputCurrency != accountCurrency) {
      final rates = ref.read(ratesProvider).valueOrNull;
      final from = rates?.rubFor(inputCurrency);
      final to = rates?.rubFor(accountCurrency);
      if (from == null || to == null || to == 0) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
              SnackBar(content: Text(context.l10n.currencyNoRate)));
        return;
      }
      amount = _amount * from / to;
      final original =
          formatMoneyIn(_amount, Currencies.symbol(inputCurrency));
      note = note.isEmpty ? '($original)' : '$note ($original)';
    }

    final tx = Tx(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      amount: amount,
      categoryId: category.id,
      date: _date,
      accountId: _accountId,
      note: note,
    );
    final notifier = ref.read(transactionsProvider.notifier);
    await (_isEditing ? notifier.update(tx) : notifier.add(tx));
    if (!mounted) return;

    // Предупредить, если операция пробила месячный лимит категории.
    if (tx.isExpense) {
      final budget = ref
          .read(budgetProgressProvider)
          .where((b) => b.category.id == tx.categoryId)
          .firstOrNull;
      if (budget != null && budget.overspent) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(context.l10n.limitExceededToast(
                budget.category.title,
                formatMoney(budget.spent),
                formatMoney(budget.limit))),
          ));
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _amount > 0 && _category != null;
    final isToday = DateUtils.isSameDay(_date, DateTime.now());
    final accountCurrency =
        ref.watch(accountsProvider).byId(_accountId).currency;
    final inputCurrency = _currencyOverride ?? accountCurrency;
    final currencySymbol = Currencies.symbol(inputCurrency);

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
              segments: [
                ButtonSegment(
                    value: TxType.expense, label: Text(context.l10n.expense)),
                ButtonSegment(
                    value: TxType.income,
                    label: Text(context.l10n.incomeSingular)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = null;
              }),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _raw,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: _type == TxType.expense
                        ? theme.colorScheme.onSurface
                        : NumoColors.mint,
                  ),
                ),
                const SizedBox(width: 6),
                // Валюта ввода: тап — выбрать другую, сумма
                // сконвертируется в валюту счёта по курсу ЦБ.
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _pickCurrency,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currencySymbol,
                          style:
                              theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded,
                            color: theme.colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final accounts = ref.watch(activeAccountsProvider);
              if (accounts.length < 2) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final a = accounts[i];
                      final selected = _accountId == a.id;
                      return ChoiceChip(
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _accountId = a.id),
                        avatar: Icon(a.icon,
                            size: 16,
                            color: selected ? Colors.white : a.color),
                        label: Text(
                            '${a.title} · ${Currencies.symbol(a.currency)}'),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                        selectedColor: a.color,
                        backgroundColor:
                            a.color.withValues(alpha: selected ? 1 : 0.10),
                        side: BorderSide.none,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      );
                    },
                  ),
                ),
              );
            }),
            SizedBox(
              height: 44,
              child: Builder(builder: (context) {
                final categories = ref
                    .watch(activeCategoriesProvider(_type == TxType.income));
                return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == categories.length) {
                    return ActionChip(
                      avatar: Icon(Icons.add_rounded,
                          size: 18, color: theme.colorScheme.onSurfaceVariant),
                      label: Text(context.l10n.newChip),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => showCategoryEditor(context,
                          isIncome: _type == TxType.income),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    );
                  }
                  final c = categories[i];
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
                        borderRadius: BorderRadius.circular(8)),
                  );
                },
              );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: context.l10n.note,
                      prefixIcon: const Icon(Icons.edit_note_rounded),
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
                const SizedBox(width: 10),
                ActionChip(
                  onPressed: _pickDate,
                  avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(
                    isToday
                        ? context.l10n.today
                        : DateFormat('d MMM', context.localeCode)
                            .format(_date),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(_isEditing
                    ? context.l10n.saveChanges
                    : _type == TxType.expense
                        ? context.l10n.addExpense
                        : context.l10n.addIncome),
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
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
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
