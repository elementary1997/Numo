import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';
import '../data/changelog.dart';
import '../state/providers.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showWhatsNew();
      await _checkForNewer();
    });
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
    ref.listen(transactionsProvider, (_, __) => schedule());
    ref.listen(categoriesProvider, (_, __) => schedule());
    ref.listen(accountsProvider, (_, __) => schedule());
    ref.listen(budgetsProvider, (_, __) => schedule());
    ref.listen(recurringProvider, (_, __) => schedule());
    ref.listen(goalsProvider, (_, __) => schedule());

    // Ненавязчивое уведомление о вышедшей версии (раз при старте).
    if (!kIsWeb) {
      ref.listen(updateCheckProvider, (previous, next) {
        final info = next.valueOrNull;
        if (info == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(context.l10n.updateAvailable(info.version)),
          action: SnackBarAction(
            label: context.l10n.download,
            onPressed: () => launchUrl(Uri.parse(info.url),
                mode: LaunchMode.externalApplication),
          ),
        ));
      });
    }
    return widget.child;
  }
}
