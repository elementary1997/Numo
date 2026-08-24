import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/backup.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../state/providers.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Экспорт всех данных в JSON-файл через системный диалог сохранения.
Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final json = Backup.encode(
    transactions: ref.read(transactionsProvider),
    categories: ref.read(categoriesProvider),
  );
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
    if (context.mounted) _toast(context, 'Бэкап сохранён');
  } on UnimplementedError {
    if (context.mounted) {
      _toast(context, 'Экспорт в файл недоступен на этой платформе');
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

  final ({List<Tx> transactions, List<TxCategory> categories}) parsed;
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
      title: const Text('Восстановить из бэкапа?'),
      content: Text(
        'Текущие данные будут полностью заменены: '
        '${parsed.transactions.length} операций и '
        '${parsed.categories.length} категорий из файла.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Заменить'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  await ref.read(categoriesProvider.notifier).replaceAll(parsed.categories);
  await ref
      .read(transactionsProvider.notifier)
      .replaceAll(parsed.transactions);
  if (context.mounted) _toast(context, 'Данные восстановлены');
}
