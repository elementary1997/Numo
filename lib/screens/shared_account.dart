import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/l10n.dart';
import '../data/members_repository.dart';
import '../data/shared_sync.dart';
import '../models/category.dart';
import '../models/member.dart';
import '../state/providers.dart';
import '../state/shared_sync_actions.dart';

/// Настройка общих счетов (ADR-0014): папка обмена, моё имя,
/// участники и ручная сверка.
class SharedAccountScreen extends ConsumerStatefulWidget {
  const SharedAccountScreen({super.key});

  @override
  ConsumerState<SharedAccountScreen> createState() =>
      _SharedAccountScreenState();
}

class _SharedAccountScreenState
    extends ConsumerState<SharedAccountScreen> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sync = ref.watch(sharedSyncProvider);
    final me = ref.watch(myMemberProvider);
    final others = ref.watch(otherMembersProvider);
    final sharedAccounts =
        ref.watch(accountsProvider).where((a) => a.shared).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.sharedTitle)),
      body: !SharedSyncService.supported
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(context.l10n.sharedWebUnsupported,
                    textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
              children: [
                Text(context.l10n.sharedIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 20),

                // Папка обмена.
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder_shared_outlined),
                        title: Text(context.l10n.sharedFolderLabel),
                        subtitle: Text(
                            sync.directory ?? context.l10n.sharedNoFolder),
                        trailing: sync.directory == null
                            ? null
                            : IconButton(
                                tooltip: context.l10n.sharedForgetFolder,
                                icon: const Icon(Icons.link_off_rounded),
                                onPressed: _disconnect,
                              ),
                        onTap: _chooseFolder,
                      ),
                      if (sync.directory != null)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              sync.lastPull == null
                                  ? context.l10n.sharedNeverSynced
                                  : context.l10n.sharedLastSync(
                                      DateFormat('d MMM, HH:mm',
                                              context.localeCode)
                                          .format(sync.lastPull!)),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(context.l10n.sharedFolderHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),

                const SizedBox(height: 20),
                // Моё имя — его увидят участники.
                if (me != null)
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: _Avatar(member: me),
                      title: Text(context.l10n.sharedMyName),
                      subtitle: Text(me.name),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editMember(me),
                    ),
                  ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.sharedMembers,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    TextButton.icon(
                      onPressed: () => _editMember(null),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(context.l10n.sharedAddMember),
                    ),
                  ],
                ),
                if (others.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(context.l10n.sharedNoMembers,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  )
                else
                  for (final member in others)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: _Avatar(member: member),
                        title: Text(member.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => _removeMember(member),
                        ),
                        onTap: () => _editMember(member),
                      ),
                    ),

                const SizedBox(height: 20),
                // Какие счета уже общие — чтобы было видно, что уедет.
                if (sharedAccounts.isNotEmpty) ...[
                  Text(context.l10n.menuAccounts,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final account in sharedAccounts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(account.icon, color: account.color),
                      title: Text(account.title),
                      subtitle: Text(context.l10n.sharedAccountToggle),
                    ),
                  const SizedBox(height: 12),
                ],

                FilledButton.icon(
                  onPressed: sync.directory == null || _syncing
                      ? null
                      : _syncNow,
                  icon: _syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync_rounded),
                  label: Text(context.l10n.sharedSyncNow),
                ),
              ],
            ),
    );
  }

  Future<void> _chooseFolder() async {
    final dir = await getDirectoryPath();
    if (dir == null) return;
    await ref.read(sharedSyncProvider).setDirectory(dir);
    if (!mounted) return;
    setState(() {});
    await _syncNow();
  }

  Future<void> _disconnect() async {
    await ref.read(sharedSyncProvider).setDirectory(null);
    if (mounted) setState(() {});
  }

  /// Сверка вручную: забрать чужие изменения и выложить свои.
  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    final applied = await syncSharedAccounts(ref);
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(applied == 0
            ? context.l10n.sharedNothingNew
            : context.l10n.sharedPulled(applied)),
      ));
  }

  Future<void> _removeMember(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sharedRemoveMemberTitle),
        content: Text(context.l10n.sharedRemoveMemberBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.removeAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(membersProvider.notifier).remove(member.id);
  }

  /// Создание участника или переименование существующего.
  Future<void> _editMember(Member? initial) async {
    final result = await showDialog<({String name, Color color})>(
      context: context,
      builder: (context) => _MemberDialog(
        initial: initial,
        fallbackColor: _paletteFor(ref.read(membersProvider)),
      ),
    );
    if (result == null || result.name.isEmpty) return;

    final notifier = ref.read(membersProvider.notifier);
    await notifier.upsert(initial == null
        ? Member(
            id: MembersRepository.newMemberId(),
            name: result.name,
            color: result.color,
          )
        : initial.copyWith(name: result.name, color: result.color));
  }

  /// Цвет для нового участника — первый неиспользованный из палитры.
  Color _paletteFor(List<Member> existing) {
    final taken = existing.map((m) => m.color.toARGB32()).toSet();
    for (final color in CategoryColors.palette) {
      if (!taken.contains(color.toARGB32())) return color;
    }
    return CategoryColors.palette.first;
  }
}

/// Кружок с инициалом участника.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        backgroundColor: member.color,
        foregroundColor: Colors.white,
        child: Text(member.initial.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

/// Диалог участника: имя и цвет. Контроллер живёт вместе с диалогом,
/// иначе он умирает раньше анимации закрытия и TextField падает.
class _MemberDialog extends StatefulWidget {
  const _MemberDialog({required this.initial, required this.fallbackColor});

  final Member? initial;
  final Color fallbackColor;

  @override
  State<_MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<_MemberDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial?.name ?? '');
  late Color _color = widget.initial?.color ?? widget.fallbackColor;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.initial == null
            ? context.l10n.sharedAddMember
            : context.l10n.sharedMemberNameLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  labelText: context.l10n.sharedMemberNameLabel),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in CategoryColors.palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = option),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: option,
                        shape: BoxShape.circle,
                        border: option == _color
                            ? Border.all(
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                                width: 2)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context)
                .pop((name: _name.text.trim(), color: _color)),
            child: Text(context.l10n.save),
          ),
        ],
      );
}
