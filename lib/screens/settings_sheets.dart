import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/sync_service.dart';
import '../state/providers.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Диалог управления PIN-защитой.
Future<void> showSecurityDialog(BuildContext context, WidgetRef ref) async {
  final security = ref.read(securityRepositoryProvider);

  if (!security.hasPin) {
    final pin = await _askPin(context, title: 'Новый PIN (4–6 цифр)');
    if (pin == null) return;
    if (!context.mounted) return;
    final confirm = await _askPin(context, title: 'Повторите PIN');
    if (confirm == null) return;
    if (pin != confirm) {
      if (context.mounted) _toast(context, 'PIN не совпал — не сохранён');
      return;
    }
    await security.setPin(pin);
    if (context.mounted) _toast(context, 'PIN установлен');
    return;
  }

  if (!context.mounted) return;
  final action = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Защита приложения'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop('change'),
          child: const ListTile(
            leading: Icon(Icons.pin_rounded),
            title: Text('Сменить PIN'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop('disable'),
          child: const ListTile(
            leading: Icon(Icons.lock_open_rounded),
            title: Text('Отключить PIN'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  );
  if (action == null || !context.mounted) return;

  final current = await _askPin(context, title: 'Текущий PIN');
  if (current == null || !security.verify(current)) {
    if (context.mounted) _toast(context, 'Неверный PIN');
    return;
  }

  if (action == 'disable') {
    await security.clear();
    if (context.mounted) _toast(context, 'PIN отключён');
    return;
  }

  if (!context.mounted) return;
  final pin = await _askPin(context, title: 'Новый PIN (4–6 цифр)');
  if (pin == null) return;
  await security.setPin(pin);
  if (context.mounted) _toast(context, 'PIN изменён');
}

Future<String?> _askPin(BuildContext context, {required String title}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: ''),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final pin = controller.text;
            if (pin.length >= 4) Navigator.of(context).pop(pin);
          },
          child: const Text('Далее'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// Диалог настройки синхронизации через папку облака.
Future<void> showSyncDialog(BuildContext context, WidgetRef ref) async {
  if (!SyncService.supported) {
    _toast(context,
        'На web синхронизация недоступна — используйте бэкап (JSON)');
    return;
  }
  final sync = ref.read(syncServiceProvider);
  final directory = sync.directory;
  final lastWrite = sync.lastWrite;

  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Синхронизация'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(directory == null
              ? 'Укажите папку, которую синхронизирует ваше облако '
                  '(Яндекс.Диск, Dropbox, Syncthing…). Numo будет держать '
                  'там файл ${SyncService.fileName} и подхватывать '
                  'изменения с других устройств.'
              : 'Папка: $directory'),
          if (lastWrite != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Последняя запись: '
                '${DateFormat('d MMM yyyy, HH:mm', 'ru').format(lastWrite)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      actions: [
        if (directory != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop('disable'),
            child: const Text('Отключить'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop('choose'),
          child: Text(directory == null ? 'Выбрать папку' : 'Сменить папку'),
        ),
      ],
    ),
  );

  if (action == 'disable') {
    await sync.setDirectory(null);
    if (context.mounted) _toast(context, 'Синхронизация отключена');
    return;
  }
  if (action != 'choose') return;

  final dir = await getDirectoryPath();
  if (dir == null) return;
  await sync.setDirectory(dir);
  await sync.writeNow(collectBackupData(ref.read));
  if (context.mounted) {
    _toast(context, 'Синхронизация включена, данные записаны');
  }
}
