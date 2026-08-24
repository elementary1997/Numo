import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
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
          group([
            item(
              icon: Icons.language_rounded,
              title: context.l10n.menuLanguage,
              onTap: () => showLanguageDialog(context, ref),
            ),
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
        ],
      ),
    );
  }
}
