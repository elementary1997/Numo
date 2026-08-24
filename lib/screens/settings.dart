import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../data/update_service.dart';
import '../state/providers.dart';
import 'backup_actions.dart';
import 'settings_sheets.dart';

/// Настройки: язык, защита, синхронизация, бэкапы и экспорт.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Widget group(List<Widget> children) => Card(
          child: Column(children: children),
        );

    Widget item({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) =>
        ListTile(
          dense: true,
          leading: Icon(icon, size: 20, color: theme.colorScheme.primary),
          title: Text(title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.chevron_right_rounded,
              size: 18, color: theme.colorScheme.onSurfaceVariant),
          onTap: onTap,
        );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.menuSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _GroupTitle(context.l10n.personalizationGroup),
          group([
            item(
              icon: Icons.language_rounded,
              title: context.l10n.menuLanguage,
              onTap: () => showLanguageDialog(context, ref),
            ),
            item(
              icon: Icons.brightness_6_rounded,
              title: context.l10n.menuTheme,
              onTap: () => showThemeDialog(context, ref),
            ),
            item(
              icon: Icons.palette_outlined,
              title: context.l10n.accentColorTitle,
              onTap: () => showAccentDialog(context, ref),
            ),
          ]),
          const SizedBox(height: 14),
          _GroupTitle(context.l10n.dataGroup),
          group([
            item(
              icon: Icons.lock_outline_rounded,
              title: context.l10n.menuSecurity,
              onTap: () => showSecurityDialog(context, ref),
            ),
            item(
              icon: Icons.cloud_sync_outlined,
              title: context.l10n.menuSync,
              onTap: () => showSyncDialog(context, ref),
            ),
            item(
              icon: Icons.folder_open_rounded,
              title: context.l10n.statementsFolderTitle,
              onTap: () => showStatementsFolderDialog(context, ref),
            ),
          ]),
          const SizedBox(height: 14),
          group([
            item(
              icon: Icons.upload_file_rounded,
              title: context.l10n.menuBackup,
              onTap: () => exportBackup(context, ref),
            ),
            item(
              icon: Icons.download_rounded,
              title: context.l10n.menuRestore,
              onTap: () => importBackup(context, ref),
            ),
            item(
              icon: Icons.grid_on_rounded,
              title: context.l10n.menuExportCsv,
              onTap: () => exportCsv(context, ref),
            ),
          ]),
          if (!kIsWeb) ...[
            const SizedBox(height: 14),
            const _UpdatesCard(),
          ],
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              dense: true,
              leading: Icon(Icons.delete_forever_rounded,
                  size: 20, color: theme.colorScheme.error),
              title: Text(context.l10n.wipeDataTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.error,
                  )),
              onTap: () => _wipeData(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

/// Заголовок группы настроек.
class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// Полный сброс данных с подтверждением.
Future<void> _wipeData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.wipeDataTitle),
      content: Text(context.l10n.wipeDataBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.wipe),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final languageCode = context.mounted
      ? Localizations.localeOf(context).languageCode
      : 'ru';
  await ref.read(transactionsProvider.notifier).replaceAll(const []);
  await ref.read(budgetsProvider.notifier).replaceAll(const {});
  await ref.read(goalsProvider.notifier).replaceAll(const []);
  await ref.read(rulesProvider.notifier).replaceAll(const []);
  await ref.read(recurringProvider.notifier).replaceAll(const []);
  await ref
      .read(categoriesProvider.notifier)
      .replaceAll(Categories.defaultsFor(languageCode));
  await ref
      .read(accountsProvider.notifier)
      .replaceAll([Accounts.mainFor(languageCode)]);
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(context.l10n.wipeDataDone)));
  }
}

/// Обновления: текущая версия, ручная проверка, автопроверка.
class _UpdatesCard extends ConsumerStatefulWidget {
  const _UpdatesCard();

  @override
  ConsumerState<_UpdatesCard> createState() => _UpdatesCardState();
}

class _UpdatesCardState extends ConsumerState<_UpdatesCard> {
  String? _version;
  bool _autoCheck = true;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    final service = ref.read(updateServiceProvider);
    service.currentVersion().then((v) {
      if (mounted) setState(() => _version = v);
    });
    service.autoCheckEnabled.then((v) {
      if (mounted) setState(() => _autoCheck = v);
    });
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final result = await ref.read(updateServiceProvider).checkManually();
    if (!mounted) return;
    setState(() => _checking = false);
    if (result.status == UpdateCheckStatus.failed) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
            SnackBar(content: Text(context.l10n.updateCheckFailed)));
      return;
    }
    final info = result.info;
    if (info == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(context.l10n.upToDate)));
      return;
    }
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.updateAvailable(info.version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.download),
          ),
        ],
      ),
    );
    if (open == true) {
      await launchUrl(Uri.parse(info.url),
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.system_update_alt_rounded,
                    size: 20, color: theme.colorScheme.primary),
            title: Text(context.l10n.checkUpdates,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: _version == null
                ? null
                : Text(context.l10n.versionLabel(_version!)),
            onTap: _checking ? null : _check,
          ),
          SwitchListTile(
            dense: true,
            secondary: Icon(Icons.update_rounded,
                size: 20, color: theme.colorScheme.primary),
            title: Text(context.l10n.autoCheckUpdates,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
            value: _autoCheck,
            onChanged: (v) async {
              setState(() => _autoCheck = v);
              await ref
                  .read(updateServiceProvider)
                  .setAutoCheckEnabled(v);
            },
          ),
        ],
      ),
    );
  }
}
