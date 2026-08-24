import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/backup.dart';
import '../data/csv.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../state/providers.dart';
import '../core/l10n.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Экспорт всех данных в JSON-файл через системный диалог сохранения.
Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final json = Backup.encode(collectBackupData(ref.read));
  final suggested =
      'numo-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';

  try {
    final location = await getSaveLocation(
      suggestedName: suggested,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json'])
      ],
    );
    if (location == null) return; // пользователь передумал
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(json)),
      mimeType: 'application/json',
      name: suggested,
    );
    await file.saveTo(location.path);
    if (context.mounted) _toast(context, context.l10n.backupSavedToast);
  } on UnimplementedError {
    if (context.mounted) {
      _toast(context, context.l10n.exportUnavailableToast);
    }
  }
}

/// Экспорт всех операций в CSV-отчёт (разделитель «;», открывается
/// русским Excel).
Future<void> exportCsv(BuildContext context, WidgetRef ref) async {
  final categories = ref.read(categoriesProvider);
  final accounts = ref.read(accountsProvider);
  final txs = ref.read(transactionsProvider);

  final csv = Csv.write([
    [
      context.l10n.csvHeaderDate,
      context.l10n.csvHeaderType,
      context.l10n.csvHeaderAmount,
      context.l10n.csvHeaderCurrency,
      context.l10n.csvHeaderCategory,
      context.l10n.csvHeaderAccount,
      context.l10n.csvHeaderNote,
    ],
    for (final t in txs)
      [
        DateFormat('dd.MM.yyyy HH:mm').format(t.date),
        t.isTransfer
            ? context.l10n.transfer
            : (t.isExpense ? context.l10n.expense : context.l10n.incomeSingular),
        t.signedAmount.toStringAsFixed(2).replaceAll('.', ','),
        accounts.byId(t.accountId).currency,
        categories.byId(t.categoryId).title,
        accounts.byId(t.accountId).title,
        t.note,
      ],
  ]);

  final suggested =
      'numo-operations-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
  try {
    final location = await getSaveLocation(
      suggestedName: suggested,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv'])
      ],
    );
    if (location == null) return;
    final file = XFile.fromData(
      // BOM, чтобы Excel открыл UTF-8 с кириллицей корректно.
      Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]),
      mimeType: 'text/csv',
      name: suggested,
    );
    await file.saveTo(location.path);
    if (context.mounted) _toast(context, context.l10n.csvSavedToast);
  } on UnimplementedError {
    if (context.mounted) {
      _toast(context, context.l10n.exportUnavailableToast);
    }
  }
}

/// Импорт бэкапа: выбор файла, валидация и — после явного
/// подтверждения — полная замена данных.
Future<void> importBackup(BuildContext context, WidgetRef ref) async {
  final file = await openFile(acceptedTypeGroups: const [
    XTypeGroup(label: 'JSON', extensions: ['json'])
  ]);
  if (file == null) return;

  final BackupData parsed;
  try {
    parsed = Backup.decode(await file.readAsString());
  } on FormatException catch (e) {
    if (context.mounted) _toast(context, e.message);
    return;
  }

  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.restoreTitle),
      content: Text(context.l10n.restoreBody(
          parsed.transactions.length, parsed.categories.length)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.replace),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  await ref.read(categoriesProvider.notifier).replaceAll(parsed.categories);
  await ref.read(accountsProvider.notifier).replaceAll(parsed.accounts);
  await ref.read(budgetsProvider.notifier).replaceAll(parsed.budgets);
  await ref.read(recurringProvider.notifier).replaceAll(parsed.recurring);
  await ref.read(goalsProvider.notifier).replaceAll(parsed.goals);
  await ref
      .read(transactionsProvider.notifier)
      .replaceAll(parsed.transactions);
  if (context.mounted) _toast(context, context.l10n.dataRestoredToast);
}
