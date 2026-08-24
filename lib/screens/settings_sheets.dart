import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_localization.dart';
import '../data/sync_service.dart';
import '../state/providers.dart';
import '../core/l10n.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Диалог управления PIN-защитой.
Future<void> showSecurityDialog(BuildContext context, WidgetRef ref) async {
  final security = ref.read(securityRepositoryProvider);

  if (!security.hasPin) {
    final pin = await _askPin(context, title: context.l10n.newPinTitle);
    if (pin == null) return;
    if (!context.mounted) return;
    final confirm = await _askPin(context, title: context.l10n.repeatPinTitle);
    if (confirm == null) return;
    if (pin != confirm) {
      if (context.mounted) _toast(context, context.l10n.pinMismatchToast);
      return;
    }
    await security.setPin(pin);
    if (context.mounted) _toast(context, context.l10n.pinSetToast);
    return;
  }

  if (!context.mounted) return;
  final action = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(context.l10n.securityTitle),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop('change'),
          child: ListTile(
            leading: const Icon(Icons.pin_rounded),
            title: Text(context.l10n.changePin),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop('disable'),
          child: ListTile(
            leading: const Icon(Icons.lock_open_rounded),
            title: Text(context.l10n.disablePin),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  );
  if (action == null || !context.mounted) return;

  final current = await _askPin(context, title: context.l10n.currentPinTitle);
  if (current == null || !security.verify(current)) {
    if (context.mounted) _toast(context, context.l10n.wrongPinToast);
    return;
  }

  if (action == 'disable') {
    await security.clear();
    if (context.mounted) _toast(context, context.l10n.pinDisabledToast);
    return;
  }

  if (!context.mounted) return;
  final pin = await _askPin(context, title: context.l10n.newPinTitle);
  if (pin == null) return;
  await security.setPin(pin);
  if (context.mounted) _toast(context, context.l10n.pinChangedToast);
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
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final pin = controller.text;
            if (pin.length >= 4) Navigator.of(context).pop(pin);
          },
          child: Text(context.l10n.next),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// Диалог выбора языка интерфейса.
Future<void> showLanguageDialog(BuildContext context, WidgetRef ref) async {
  final current = ref.read(localeOverrideProvider);
  final chosen = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(context.l10n.menuLanguage),
      children: [
        for (final (value, label) in [
          ('system', context.l10n.languageSystem),
          ('ru', context.l10n.languageRussian),
          ('en', context.l10n.languageEnglish),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(value),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                (current ?? 'system') == value
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
              ),
              title: Text(label),
            ),
          ),
      ],
    ),
  );
  if (chosen == null) return;
  final newValue = chosen == 'system' ? null : chosen;
  ref.read(localeOverrideProvider.notifier).state = newValue;
  final prefs = await SharedPreferences.getInstance();
  if (newValue == null) {
    await prefs.remove('numo.locale');
  } else {
    await prefs.setString('numo.locale', newValue);
  }

  // Названия встроенных категорий/счёта следуют выбранному языку.
  final effective = newValue ??
      (WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ru'
          ? 'ru'
          : 'en');
  await relocalizeSeedData(
    categories: ref.read(categoriesRepositoryProvider),
    accounts: ref.read(accountsRepositoryProvider),
    languageCode: effective,
  );
  ref.invalidate(categoriesProvider);
  ref.invalidate(accountsProvider);
}

/// Диалог выбора темы оформления.
Future<void> showThemeDialog(BuildContext context, WidgetRef ref) async {
  final current = ref.read(themeOverrideProvider);
  final chosen = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(context.l10n.menuTheme),
      children: [
        for (final (value, label) in [
          ('system', context.l10n.themeSystem),
          ('light', context.l10n.themeLight),
          ('dark', context.l10n.themeDark),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(value),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                (current ?? 'system') == value
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
              ),
              title: Text(label),
            ),
          ),
      ],
    ),
  );
  if (chosen == null) return;
  final newValue = chosen == 'system' ? null : chosen;
  ref.read(themeOverrideProvider.notifier).state = newValue;
  final prefs = await SharedPreferences.getInstance();
  if (newValue == null) {
    await prefs.remove('numo.theme');
  } else {
    await prefs.setString('numo.theme', newValue);
  }
}

/// Диалог настройки синхронизации через папку облака.
Future<void> showSyncDialog(BuildContext context, WidgetRef ref) async {
  if (!SyncService.supported) {
    _toast(context, context.l10n.syncWebUnavailable);
    return;
  }
  final sync = ref.read(syncServiceProvider);
  final directory = sync.directory;
  final lastWrite = sync.lastWrite;

  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.syncTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(directory == null
              ? context.l10n.syncExplainer(SyncService.fileName)
              : context.l10n.syncFolder(directory)),
          if (lastWrite != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.syncLastWrite(
                    DateFormat('d MMM yyyy, HH:mm', context.localeCode)
                        .format(lastWrite)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      actions: [
        if (directory != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop('disable'),
            child: Text(context.l10n.disable),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop('choose'),
          child: Text(directory == null ? context.l10n.chooseFolder : context.l10n.changeFolder),
        ),
      ],
    ),
  );

  if (action == 'disable') {
    await sync.setDirectory(null);
    if (context.mounted) _toast(context, context.l10n.syncDisabledToast);
    return;
  }
  if (action != 'choose') return;

  final dir = await getDirectoryPath();
  if (dir == null) return;
  await sync.setDirectory(dir);
  await sync.writeNow(collectBackupData(ref.read));
  if (context.mounted) {
    _toast(context, context.l10n.syncEnabledToast);
  }
}
