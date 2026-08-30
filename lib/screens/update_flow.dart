import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n.dart';
import '../data/self_updater.dart';
import '../data/update_service.dart';

/// Единый сценарий обновления: скачать и установить самим, а если
/// на платформе это невозможно или что-то пошло не так — открыть
/// страницу релиза.
Future<void> runUpdateFlow(BuildContext context, UpdateInfo info) async {
  final assetUrl = info.assetUrl;
  if (!SelfUpdater.supported || assetUrl == null) {
    await launchUrl(Uri.parse(info.url),
        mode: LaunchMode.externalApplication);
    return;
  }

  // Папка установки недоступна для записи (Program Files и подобное):
  // качать 30 МБ, чтобы упереться в права, незачем.
  if (!SelfUpdater.canWriteToInstallDir()) {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.updateFailed),
        content: Text(context.l10n.updateNoWriteAccess),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.openPage),
          ),
        ],
      ),
    );
    if (open == true) {
      await launchUrl(Uri.parse(info.url),
          mode: LaunchMode.externalApplication);
    }
    return;
  }

  final progress = ValueNotifier<double?>(null);
  String? failure;

  // Диалог прогресса; закроется сам только при ошибке —
  // при успехе приложение завершится для подмены файлов.
  final dialog = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.updating),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<double?>(
            valueListenable: progress,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.updateRestartNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    ),
  );

  try {
    // Ставим отметку до выхода: если подмена файлов не удастся,
    // при следующем запуске приложение об этом скажет.
    await UpdateService().markPending(info.version);
    await SelfUpdater.downloadAndInstall(
      assetUrl,
      onProgress: (value) => progress.value = value,
    );
  } catch (e) {
    failure = '$e';
    // Скачивание не дошло до подмены файлов — отметку о начатой
    // установке снимаем, иначе при следующем запуске приложение
    // соврёт, будто обновление не встало.
    await UpdateService().clearPending();
  }

  if (failure == null) return; // при успехе приложение уже вышло

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop(); // закрыть прогресс
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.updateFailed),
        // Настоящая причина — чтобы проблему можно было понять,
        // а не гадать по «что-то пошло не так».
        content: Text(failure!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.openPage),
          ),
        ],
      ),
    );
    if (open == true) {
      await launchUrl(Uri.parse(info.url),
          mode: LaunchMode.externalApplication);
    }
  }
  await dialog;
}
