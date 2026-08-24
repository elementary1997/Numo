import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../core/brands.dart';
import '../widgets/account_avatar.dart';
import '../widgets/breakdown_card.dart';
import '../state/providers.dart';
import '../core/l10n.dart';

/// Название типа счёта на языке интерфейса.
String accountKindLabel(BuildContext context, AccountKind kind) =>
    switch (kind) {
      AccountKind.card => context.l10n.accountTypeCard,
      AccountKind.cash => context.l10n.accountTypeCash,
      AccountKind.deposit => context.l10n.accountTypeDeposit,
      AccountKind.savings => context.l10n.accountTypeSavings,
    };

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider);
    final active = accounts.where((a) => !a.archived).toList();
    final archived = accounts.where((a) => a.archived).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.menuAccounts),
        actions: [
          if (active.length >= 2)
            IconButton(
              tooltip: context.l10n.transferBetweenAccounts,
              onPressed: () => showTransferSheet(context),
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAccountEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.newAccount),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          const _CapitalBreakdown(),
          for (final kind in AccountKind.values)
            if (active.any((a) => a.kind == kind)) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
                child: Text(
                  accountKindLabel(context, kind),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              for (final a in active.where((a) => a.kind == kind))
                _AccountTile(account: a),
            ],
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(context.l10n.archiveSection,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            for (final a in archived)
              Opacity(opacity: 0.45, child: _AccountTile(account: a)),
          ],
        ],
      ),
    );
  }
}

/// Структура капитала: доли счетов в рублёвом эквиваленте.
class _CapitalBreakdown extends ConsumerWidget {
  const _CapitalBreakdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(activeAccountsProvider);
    if (accounts.length < 2) return const SizedBox.shrink();
    final rates = ref.watch(ratesProvider).valueOrNull;

    final entries = <BreakdownEntry>[];
    for (final a in accounts) {
      final balance = ref.watch(accountBalanceProvider(a.id));
      final rate = a.isRub ? 1.0 : rates?.rubFor(a.currency);
      if (balance <= 0 || rate == null) continue;
      entries.add(BreakdownEntry(
        title: a.title,
        color: a.color,
        value: balance * rate,
      ));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    if (entries.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BreakdownCard(
        title: context.l10n.capitalStructure,
        entries: entries,
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final balance = ref.watch(accountBalanceProvider(account.id));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () => showAccountEditor(context, initial: account),
      leading: AccountAvatar(account: account),
      title: Text(account.title,
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(
        account.kind == AccountKind.savings && account.rate != null
            ? '${accountKindLabel(context, account.kind)} · ${account.rate! == account.rate!.roundToDouble() ? account.rate!.toStringAsFixed(0) : account.rate!} %'
            : account.isDeposit &&
                    account.rate != null &&
                    account.closesAt != null
            ? context.l10n.depositBadge(
                account.rate! == account.rate!.roundToDouble()
                    ? account.rate!.toStringAsFixed(0)
                    : account.rate!.toString(),
                DateFormat('dd.MM.yyyy').format(account.closesAt!),
              )
            : account.currency,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatMoneyIn(balance, Currencies.symbol(account.currency)),
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (account.projectedAtClose(balance) != null)
            Text(
              context.l10n.projectedAtClose(formatMoneyIn(
                  account.projectedAtClose(balance)!,
                  Currencies.symbol(account.currency))),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            tooltip: account.archived ? context.l10n.fromArchive : context.l10n.toArchive,
            icon: Icon(
              account.archived
                  ? Icons.unarchive_rounded
                  : Icons.archive_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => ref
                .read(accountsProvider.notifier)
                .setArchived(account.id, !account.archived),
          ),
        ],
      ),
    );
  }
}

/// Sheet создания/редактирования счёта.
Future<void> showAccountEditor(BuildContext context, {Account? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (_) => _AccountEditor(initial: initial),
  );
}

class _AccountEditor extends ConsumerStatefulWidget {
  const _AccountEditor({this.initial});

  final Account? initial;

  @override
  ConsumerState<_AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends ConsumerState<_AccountEditor> {
  late final TextEditingController _title;
  late final TextEditingController _balance;
  late final TextEditingController _rate;
  late String _iconKey;
  late Color _color;
  late String _currency;
  late AccountKind _kind;
  DateTime? _openedAt;
  DateTime? _closesAt;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _title = TextEditingController(text: a?.title ?? '');
    final currentBalance =
        a == null ? 0.0 : ref.read(accountBalanceProvider(a.id));
    _balance = TextEditingController(
        text: a == null
            ? ''
            : currentBalance == currentBalance.roundToDouble()
                ? currentBalance.toStringAsFixed(0)
                : currentBalance.toStringAsFixed(2).replaceAll('.', ','));
    _rate = TextEditingController(
        text: a?.rate == null
            ? ''
            : a!.rate! == a.rate!.roundToDouble()
                ? a.rate!.toStringAsFixed(0)
                : a.rate!.toString());
    _iconKey = a?.iconKey ?? 'card';
    _color = a?.color ?? CategoryColors.palette.first;
    _currency = a?.currency ?? Currencies.rub;
    _kind = a?.kind ?? AccountKind.card;
    _openedAt = a?.openedAt;
    _closesAt = a?.closesAt;
  }

  @override
  void dispose() {
    _title.dispose();
    _balance.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool opened}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: opened ? (_openedAt ?? now) : (_closesAt ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) {
      setState(() => opened ? _openedAt = picked : _closesAt = picked);
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final isDeposit = _kind == AccountKind.deposit;
    final withRate =
        isDeposit || _kind == AccountKind.savings;
    final account = Account(
      id: widget.initial?.id ??
          'acc-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      iconKey: _iconKey,
      color: _color,
      currency: _currency,
      archived: widget.initial?.archived ?? false,
      kind: _kind,
      rate: withRate
          ? double.tryParse(_rate.text.replaceAll(',', '.'))
          : null,
      openedAt: isDeposit ? (_openedAt ?? DateTime.now()) : null,
      closesAt: isDeposit ? _closesAt : null,
    );
    await ref.read(accountsProvider.notifier).upsert(account);

    // Введённый баланс отличается от фактического — создаём системную
    // корректировку, не влияющую на статистику доходов/расходов.
    final entered =
        double.tryParse(_balance.text.replaceAll(' ', '').replaceAll(',', '.'));
    if (entered != null) {
      final current = widget.initial == null
          ? 0.0
          : ref.read(accountBalanceProvider(account.id));
      final diff = entered - current;
      if (diff.abs() >= 0.01) {
        await ref.read(transactionsProvider.notifier).add(Tx(
              id: 'adj-${DateTime.now().microsecondsSinceEpoch}',
              type: diff > 0 ? TxType.income : TxType.expense,
              amount: diff.abs(),
              categoryId: Categories.adjustment.id,
              date: DateTime.now(),
              accountId: account.id,
            ));
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const icons = ['card', 'cash', 'savings', 'work', 'percent', 'gift'];

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
              _isEditing ? context.l10n.editAccount : context.l10n.newAccount,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                ),
                const SizedBox(width: 10),
                DropdownMenu<String>(
                  initialSelection: _currency,
                  label: Text(context.l10n.currencyLabel),
                  width: 130,
                  onSelected: (v) =>
                      setState(() => _currency = v ?? Currencies.rub),
                  dropdownMenuEntries: [
                    for (final c in Currencies.supported)
                      DropdownMenuEntry(
                          value: c,
                          label: '$c ${Currencies.symbol(c)}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _balance,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[-0-9., ]')),
              ],
              decoration: InputDecoration(
                labelText:
                    '${context.l10n.accountBalanceLabel}, ${Currencies.symbol(_currency)}',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in AccountKind.values)
                  ChoiceChip(
                    selected: _kind == kind,
                    onSelected: (_) => setState(() => _kind = kind),
                    label: Text(accountKindLabel(context, kind)),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _kind == kind
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                    selectedColor: NumoColors.violet,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
              ],
            ),
            if (_kind == AccountKind.deposit ||
                _kind == AccountKind.savings) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rate,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: context.l10n.rateLabel,
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
                ],
              ),
              if (_kind == AccountKind.deposit) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ActionChip(
                      avatar: const Icon(Icons.event_rounded, size: 16),
                      label: Text(
                        '${context.l10n.openedLabel}: '
                        '${_openedAt == null ? '—' : DateFormat('dd.MM.yyyy').format(_openedAt!)}',
                      ),
                      onPressed: () => _pickDate(opened: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActionChip(
                      avatar:
                          const Icon(Icons.event_available_rounded, size: 16),
                      label: Text(
                        '${context.l10n.closesLabel}: '
                        '${_closesAt == null ? '—' : DateFormat('dd.MM.yyyy').format(_closesAt!)}',
                      ),
                      onPressed: () => _pickDate(opened: false),
                    ),
                  ),
                ],
              ),
              ],
            ],
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
                // Брендовые бейджи банков и сервисов: выбор бренда
                // заодно красит счёт в фирменный цвет.
                for (final brand in brands)
                  _pickTile(
                    theme: theme,
                    selected: _iconKey == 'brand:${brand.key}',
                    color: brand.background,
                    onTap: () => setState(() {
                      _iconKey = 'brand:${brand.key}';
                      _color = brand.background;
                    }),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: brand.background,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        brand.label,
                        style: TextStyle(
                          color: brand.foreground,
                          fontWeight: FontWeight.w800,
                          fontSize: brand.label.length > 1 ? 9 : 14,
                        ),
                      ),
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
                onPressed: _title.text.trim().isEmpty ? null : _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(_isEditing ? context.l10n.save : context.l10n.create),
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

/// Sheet перевода между счетами.
Future<void> showTransferSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (_) => const _TransferSheet(),
  );
}

class _TransferSheet extends ConsumerStatefulWidget {
  const _TransferSheet();

  @override
  ConsumerState<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<_TransferSheet> {
  final _amountFrom = TextEditingController();
  final _amountTo = TextEditingController();
  Account? _from;
  Account? _to;

  @override
  void dispose() {
    _amountFrom.dispose();
    _amountTo.dispose();
    super.dispose();
  }

  bool get _crossCurrency =>
      _from != null && _to != null && _from!.currency != _to!.currency;

  Future<void> _save() async {
    final from = _from;
    final to = _to;
    final amountFrom =
        double.tryParse(_amountFrom.text.replaceAll(',', '.'));
    if (from == null || to == null || from.id == to.id) return;
    if (amountFrom == null || amountFrom <= 0) return;
    final amountTo = _crossCurrency
        ? double.tryParse(_amountTo.text.replaceAll(',', '.'))
        : amountFrom;
    if (amountTo == null || amountTo <= 0) return;

    await ref.read(transactionsProvider.notifier).createTransfer(
          from: from,
          to: to,
          amountFrom: amountFrom,
          amountTo: amountTo,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(activeAccountsProvider);
    final canSave = _from != null &&
        _to != null &&
        _from!.id != _to!.id &&
        (double.tryParse(_amountFrom.text.replaceAll(',', '.')) ?? 0) > 0 &&
        (!_crossCurrency ||
            (double.tryParse(_amountTo.text.replaceAll(',', '.')) ?? 0) > 0);

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
            Text(context.l10n.transferBetweenAccounts,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownMenu<Account>(
                    label: Text(context.l10n.fromAccount),
                    expandedInsets: EdgeInsets.zero,
                    onSelected: (v) => setState(() => _from = v),
                    dropdownMenuEntries: [
                      for (final a in accounts)
                        DropdownMenuEntry(value: a, label: a.title),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 20),
                ),
                Expanded(
                  child: DropdownMenu<Account>(
                    label: Text(context.l10n.toAccount),
                    expandedInsets: EdgeInsets.zero,
                    onSelected: (v) => setState(() => _to = v),
                    dropdownMenuEntries: [
                      for (final a in accounts)
                        DropdownMenuEntry(value: a, label: a.title),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountFrom,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _from == null
                    ? context.l10n.amountLabel
                    : context.l10n
                        .amountInCurrency(Currencies.symbol(_from!.currency)),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_crossCurrency) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _amountTo,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: context.l10n
                      .creditedInCurrency(Currencies.symbol(_to!.currency)),
                  helperText: context.l10n.currenciesDifferHint,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(context.l10n.transferButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
