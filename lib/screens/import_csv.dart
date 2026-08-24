import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../data/csv.dart';
import '../data/statement_import.dart';
import '../data/statement_parsers.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../core/l10n.dart';

/// Импорт банковской выписки из CSV: выбор файла → маппинг колонок →
/// предпросмотр с дедупликацией → импорт.
class ImportCsvScreen extends ConsumerStatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  ConsumerState<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends ConsumerState<ImportCsvScreen> {
  List<List<String>>? _rows;
  int? _dateColumn;
  int? _amountColumn;
  int? _noteColumn;
  bool _unsignedIsExpense = false;
  String? _accountId;

  int get _columnCount =>
      _rows == null ? 0 : _rows!.map((r) => r.length).reduce((a, b) => a > b ? a : b);

  Future<void> _pickFile() async {
    final file = await openFile(acceptedTypeGroups: const [
      XTypeGroup(
          label: 'Statements',
          extensions: ['csv', 'txt', 'ofx', 'xlsx'])
    ]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final rows = switch (detectFormat(file.name, bytes)) {
      StatementFormat.ofx =>
        parseOfx(utf8.decode(bytes, allowMalformed: true)),
      StatementFormat.xlsx => parseXlsx(bytes),
      StatementFormat.csv =>
        Csv.parse(utf8.decode(bytes, allowMalformed: true)),
    };
    if (rows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.fileEmptyToast)));
      }
      return;
    }
    final guessed = StatementImporter.guessMapping(rows.first);
    setState(() {
      _rows = rows;
      _dateColumn = guessed?.dateColumn;
      _amountColumn = guessed?.amountColumn;
      _noteColumn = guessed?.noteColumn;
    });
  }

  ColumnMapping? get _mapping =>
      _dateColumn == null || _amountColumn == null
          ? null
          : ColumnMapping(
              dateColumn: _dateColumn!,
              amountColumn: _amountColumn!,
              noteColumn: _noteColumn,
              unsignedIsExpense: _unsignedIsExpense,
            );

  List<ParsedRow> _parse() {
    final mapping = _mapping;
    if (_rows == null || mapping == null) return const [];
    return StatementImporter.parseRows(
      rows: _rows!,
      mapping: mapping,
      accountId: _accountId ??
          ref.read(activeAccountsProvider).firstOrNull?.id ??
          Accounts.main.id,
      rules: ref.read(rulesProvider),
      existingIds:
          ref.read(transactionsProvider).map((t) => t.id).toSet(),
      skipFirstRow: StatementImporter.hasHeader(_rows!, mapping),
    );
  }

  Future<void> _import(List<ParsedRow> parsed) async {
    final toImport =
        parsed.where((r) => r.importable).map((r) => r.tx!).toList();
    if (toImport.isEmpty) return;
    final notifier = ref.read(transactionsProvider.notifier);
    await notifier.replaceAll([
      ...ref.read(transactionsProvider),
      ...toImport,
    ]);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text(context.l10n.importedToast(toImport.length))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(activeAccountsProvider);
    final parsed = _parse();
    final importable = parsed.where((r) => r.importable).length;
    final duplicates = parsed.where((r) => r.duplicate).length;
    final skipped =
        parsed.where((r) => r.tx == null).length;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.importStatementTitle)),
      body: _rows == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.table_view_rounded,
                      size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.chooseCsvPrompt,
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(context.l10n.chooseFile),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Text(context.l10n.columnsLabel,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _columnPicker(context.l10n.colDate, _dateColumn,
                        (v) => setState(() => _dateColumn = v)),
                    _columnPicker(context.l10n.colAmount, _amountColumn,
                        (v) => setState(() => _amountColumn = v)),
                    _columnPicker(context.l10n.colDescription, _noteColumn,
                        (v) => setState(() => _noteColumn = v),
                        allowNone: true),
                    if (accounts.length > 1)
                      DropdownMenu<String>(
                        initialSelection:
                            _accountId ?? accounts.first.id,
                        label: Text(context.l10n.accountLabel),
                        width: 180,
                        onSelected: (v) =>
                            setState(() => _accountId = v),
                        dropdownMenuEntries: [
                          for (final a in accounts)
                            DropdownMenuEntry(
                                value: a.id, label: a.title),
                        ],
                      ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.unsignedIsExpense),
                  subtitle: Text(context.l10n.unsignedIsExpenseHint),
                  value: _unsignedIsExpense,
                  onChanged: (v) =>
                      setState(() => _unsignedIsExpense = v),
                ),
                const Divider(height: 24),
                Text(
                  context.l10n.importSummary(importable, duplicates, skipped),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final row in parsed.take(8)) _PreviewTile(row: row),
                if (parsed.length > 8)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(context.l10n.moreRows(parsed.length - 8),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed:
                        importable > 0 ? () => _import(parsed) : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(context.l10n.importButton(importable)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _columnPicker(
      String label, int? value, ValueChanged<int?> onChanged,
      {bool allowNone = false}) {
    final sample = _rows!.length > 1 ? _rows![1] : _rows!.first;
    String columnLabel(int i) {
      final example = i < sample.length ? sample[i] : '';
      final trimmed =
          example.length > 14 ? '${example.substring(0, 14)}…' : example;
      return trimmed.isEmpty ? context.l10n.columnN(i + 1) : '${i + 1}: $trimmed';
    }

    return DropdownMenu<int>(
      initialSelection: value ?? (allowNone ? -1 : null),
      label: Text(label),
      width: 190,
      onSelected: (v) => onChanged(v == -1 ? null : v),
      dropdownMenuEntries: [
        if (allowNone)
          DropdownMenuEntry(value: -1, label: context.l10n.noneOption),
        for (var i = 0; i < _columnCount; i++)
          DropdownMenuEntry(value: i, label: columnLabel(i)),
      ],
    );
  }
}

class _PreviewTile extends ConsumerWidget {
  const _PreviewTile({required this.row});

  final ParsedRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tx = row.tx;
    if (tx == null) {
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.help_outline_rounded,
            color: theme.colorScheme.onSurfaceVariant, size: 20),
        title: Text(
          row.source.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Text(context.l10n.skippedRow,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      );
    }
    final category = ref.watch(categoriesProvider).byId(tx.categoryId);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(category.icon, color: category.color, size: 20),
      title: Text(
        tx.note.isEmpty ? category.title : tx.note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          decoration: row.duplicate ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
          '${DateFormat('d MMM yyyy', context.localeCode).format(tx.date)} · ${category.title}'),
      trailing: row.duplicate
          ? Text(context.l10n.duplicateRow,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          : Text(
              formatSigned(tx.amount, isExpense: tx.isExpense),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
    );
  }
}
