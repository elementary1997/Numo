import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';
import '../data/changelog.dart';
import '../data/statements_watcher.dart';
import '../state/providers.dart';
import '../state/shared_sync_actions.dart';
import 'import_csv.dart';
import 'update_flow.dart';

/// Обвязка синхронизации вокруг приложения: при старте предлагает
/// принять более новые данные из папки синхронизации, а изменения
/// данных записывает туда с дебаунсом.
class SyncRoot extends ConsumerStatefulWidget {
  const SyncRoot({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncRoot> createState() => _SyncRootState();
}

class _SyncRootState extends ConsumerState<SyncRoot> {
  Timer? _updateRecheck;
  AppLifecycleListener? _lifecycle;

  /// Версия, о которой уже показано уведомление, — чтобы
  /// перепроверки не спамили одним и тем же снекбаром.
  String? _notifiedUpdateVersion;

  /// Первый ответ проверки обновлений уже получен — дальше о новой
  /// версии можно говорить снекбаром.
  bool _firstUpdateCheckSeen = false;

  /// Когда общие счета сверялись в последний раз — окно на desktop
  /// получает фокус часто, дёргать облако на каждый щелчок незачем.
  DateTime? _lastResumeSync;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showWhatsNew();
      await _reportFailedUpdate();
      await _checkForNewer();
      await _pullShared();
      await _checkStatements();
    });
    // Desktop-приложение живёт открытым днями — одной проверки при
    // старте мало, чтобы узнать о вышедшем релизе. Перепроверяем
    // раз в час и при возврате фокуса окна (сетевой запрос при этом
    // ограничен часовым кэшем UpdateService).
    if (!kIsWeb) {
      _updateRecheck = Timer.periodic(const Duration(hours: 1),
          (_) => ref.invalidate(updateCheckProvider));
      _lifecycle = AppLifecycleListener(onResume: () {
        ref.invalidate(updateCheckProvider);
        // Пока Numo был свёрнут, второй участник мог что-то добавить.
        _syncSharedOnResume();
      });
    }
  }

  @override
  void dispose() {
    _updateRecheck?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  /// Новые файлы в папке выписок: предлагаем импорт первого из них.
  Future<void> _checkStatements() async {
    if (kIsWeb) return;
    final found = await StatementsWatcher.scan();
    if (found.isEmpty || !mounted) return;
    final statement = found.first;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(context.l10n.statementFound(statement.name)),
      action: SnackBarAction(
        label: context.l10n.importAction,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ImportCsvScreen(initialFilePath: statement.path))),
      ),
    ));
  }

  /// После обновления показывает «Что нового» для текущей версии.
  Future<void> _showWhatsNew() async {
    final prefs = await SharedPreferences.getInstance();
    final current = (await PackageInfo.fromPlatform()).version;
    final lastSeen = prefs.getString('numo.lastSeenVersion');
    await prefs.setString('numo.lastSeenVersion', current);
    if (lastSeen == null || lastSeen == current || !mounted) return;

    final entry =
        changelog.where((e) => e.version == current).firstOrNull;
    if (entry == null) return;
    final lang = Localizations.localeOf(context).languageCode;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.whatsNewTitle(current)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in entry.items(lang))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  /// Если прошлое обновление не встало (частый случай на Windows —
  /// нет прав на папку установки), говорим об этом прямо и предлагаем
  /// скачать сборку руками.
  Future<void> _reportFailedUpdate() async {
    if (kIsWeb) return;
    final failed =
        await ref.read(updateServiceProvider).takeFailedUpdate();
    if (failed == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 12),
      content: Text(context.l10n.updateDidNotApply(failed)),
      action: SnackBarAction(
        label: context.l10n.openPage,
        onPressed: () => launchUrl(
          Uri.parse('https://github.com/elementary1997/Numo/releases/latest'),
          mode: LaunchMode.externalApplication,
        ),
      ),
    ));
  }

  /// Общие счета (ADR-0014): при запуске забираем файлы участников,
  /// сливаем изменения и выкладываем свой файл.
  Future<void> _pullShared() async {
    if (!ref.read(sharedSyncProvider).enabled) return;
    final applied = await syncSharedAccounts(ref);
    if (applied == 0 || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.sharedPulled(applied))),
    );
  }

  /// Тихая сверка общих счетов при возврате в приложение, не чаще
  /// раза в минуту.
  Future<void> _syncSharedOnResume() async {
    if (!ref.read(sharedSyncProvider).enabled) return;
    final last = _lastResumeSync;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 1)) {
      return;
    }
    _lastResumeSync = DateTime.now();
    final applied = await syncSharedAccounts(ref);
    if (applied == 0 || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.sharedPulled(applied))),
    );
  }

  Future<void> _checkForNewer() async {
    final newer = await ref.read(syncServiceProvider).checkForNewer();
    if (newer == null || !mounted) return;
    final (data, exportedAt) = newer;

    final accept = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.syncNewerTitle),
        content: Text(context.l10n.syncNewerBody(
          DateFormat('d MMM yyyy, HH:mm', context.localeCode)
              .format(exportedAt),
          data.transactions.length,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.keepMine),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.accept),
          ),
        ],
      ),
    );
    if (accept != true) return;

    await ref.read(categoriesProvider.notifier).replaceAll(data.categories);
    await ref.read(accountsProvider.notifier).replaceAll(data.accounts);
    await ref.read(budgetsProvider.notifier).replaceAll(data.budgets);
    await ref.read(recurringProvider.notifier).replaceAll(data.recurring);
    await ref.read(goalsProvider.notifier).replaceAll(data.goals);
    await ref
        .read(transactionsProvider.notifier)
        .replaceAll(data.transactions);
    await ref.read(syncServiceProvider).markAccepted(exportedAt);
  }

  @override
  Widget build(BuildContext context) {
    // Любое изменение данных — отложенная запись в папку синхронизации.
    void schedule() => ref
        .read(syncServiceProvider)
        .scheduleWrite(() => collectBackupData(ref.read));
    // Изменения общих счетов дополнительно уезжают в папку обмена.
    void schedulePublish() => ref.read(sharedSyncProvider).schedulePublish(
        () => collectSharedData(ref.read, ref.read(repositoryProvider)));
    ref.listen(transactionsProvider, (_, __) {
      schedule();
      schedulePublish();
    });
    ref.listen(categoriesProvider, (_, __) => schedule());
    ref.listen(accountsProvider, (_, __) {
      schedule();
      schedulePublish();
    });
    ref.listen(budgetsProvider, (_, __) => schedule());
    ref.listen(recurringProvider, (_, __) => schedule());
    ref.listen(goalsProvider, (_, __) => schedule());

    // Ненавязчивое уведомление о вышедшей версии — один раз на
    // версию за сессию (перепроверки идут раз в час и по фокусу).
    if (!kIsWeb) {
      ref.listen(updateCheckProvider, (previous, next) {
        final info = next.valueOrNull;
        if (info == null || info.version == _notifiedUpdateVersion) return;
        // Про отложенную версию напоминает только баннер на дашборде.
        if (info.version == ref.read(dismissedUpdateProvider)) return;
        // При запуске о версии говорит баннер на дашборде; снекбар
        // нужен для другого случая — окно открыто, и релиз вышел
        // прямо сейчас, а пользователь смотрит не на «Обзор».
        if (!_firstUpdateCheckSeen) {
          _firstUpdateCheckSeen = true;
          _notifiedUpdateVersion = info.version;
          return;
        }
        _notifiedUpdateVersion = info.version;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(context.l10n.updateAvailable(info.version)),
          action: SnackBarAction(
            label: context.l10n.updateNow,
            onPressed: () => runUpdateFlow(context, info),
          ),
        ));
      });
    }
    return widget.child;
  }
}
