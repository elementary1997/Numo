import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/l10n.dart';
import '../data/members_repository.dart';
import '../data/settlements.dart';
import '../data/shared_sync.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/member.dart';
import '../state/providers.dart';
import '../widgets/qr_code.dart';
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
                    child: Column(
                      children: [
                        ListTile(
                          leading: _Avatar(member: me),
                          title: Text(context.l10n.sharedMyName),
                          subtitle: Text(me.name),
                          trailing: const Icon(Icons.edit_outlined),
                          onTap: () => _editMember(me),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.qr_code_rounded),
                          title: Text(context.l10n.sharedMyCode),
                          subtitle: Text(context.l10n.sharedMyCodeHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                          trailing: TextButton(
                            onPressed: () => _showMyCode(me),
                            child: Text(context.l10n.sharedShowCode),
                          ),
                          onTap: () => _showMyCode(me),
                        ),
                      ],
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
                      onPressed: _addByCode,
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
                _DebtsSection(onSettle: _settle),

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

  /// Свой код приглашения — показываем крупно и даём скопировать.
  Future<void> _showMyCode(Member me) async {
    final theme = Theme.of(context);
    final copied = context.l10n.sharedCodeCopied;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sharedMyCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Рядом сидящему проще снять код телефоном, чем пересылать.
            Center(
              child: InviteQr(
                data: me.inviteCode,
                semanticsLabel: context.l10n.sharedMyCode,
              ),
            ),
            const SizedBox(height: 14),
            SelectableText(
              me.inviteCode,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace', fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(context.l10n.sharedMyCodeHint,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close),
          ),
          FilledButton.icon(
            onPressed: () {
              // Буфер обмена заполняем без ожидания: после await
              // контекст диалога уже закрыт.
              Clipboard.setData(ClipboardData(text: me.inviteCode));
              Navigator.of(context).pop();
              _toast(copied);
            },
            icon: const Icon(Icons.copy_rounded),
            label: Text(context.l10n.sharedCopyCode),
          ),
        ],
      ),
    );
  }

  /// Добавление участника по коду, который прислал близкий: код несёт
  /// его настоящий идентификатор, поэтому операции из его файла сразу
  /// подписываются его именем — ждать первой сверки не нужно.
  Future<void> _addByCode() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _InviteCodeDialog(),
    );
    if (result == null) return;

    if (result == _InviteCodeDialog.manualEntry) {
      await _editMember(null);
      return;
    }

    final member = Member.fromInviteCode(result);
    if (!mounted) return;
    if (member == null) {
      _toast(context.l10n.sharedCodeInvalid);
      return;
    }
    if (member.id == ref.read(myMemberIdProvider)) {
      _toast(context.l10n.sharedCodeIsMine);
      return;
    }
    await ref.read(membersProvider.notifier).upsert(member);
    if (!mounted) return;
    _toast(context.l10n.sharedMemberAdded(member.name));
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));

  /// Погашение долга: платёж должника кредитору. В расчёте это трата
  /// должника, целиком приходящаяся на кредитора, — она и обнуляет счёт.
  Future<void> _settle(Debt debt) async {
    final members = ref.read(membersProvider);
    final from = members.tryById(debt.from);
    final to = members.tryById(debt.to);
    if (from == null || to == null) return;
    final account = ref
        .read(accountsProvider)
        .firstWhere((a) => a.shared, orElse: () => Accounts.main);

    await ref.read(transactionsProvider.notifier).add(Tx(
          id: 'settle-${DateTime.now().microsecondsSinceEpoch}',
          type: TxType.expense,
          amount: debt.amount,
          categoryId: Categories.adjustment.id,
          date: DateTime.now(),
          accountId: account.id,
          note: context.l10n.settleNote(from.name, to.name),
          authorId: from.id,
          split: {to.id: 1},
        ));
    if (!mounted) return;
    _toast(context.l10n.settleDone);
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

/// Ввод кода приглашения. Возвращает код, [manualEntry] — если человек
/// предпочёл завести карточку руками.
class _InviteCodeDialog extends StatefulWidget {
  const _InviteCodeDialog();

  static const manualEntry = '__manual__';

  @override
  State<_InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<_InviteCodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.l10n.sharedAddByCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _code,
              autofocus: true,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                labelText: context.l10n.sharedCodeLabel,
                hintText: Member.invitePrefix,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop(_InviteCodeDialog.manualEntry),
              child: Text(context.l10n.sharedAddManually),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: _code.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_code.text),
            child: Text(context.l10n.sharedAddMember),
          ),
        ],
      );
}

/// «Кто кому должен»: итог взаимных трат и кнопка расчёта.
class _DebtsSection extends ConsumerWidget {
  const _DebtsSection({required this.onSettle});

  final Future<void> Function(Debt debt) onSettle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debts = ref.watch(debtsProvider);
    final members = ref.watch(membersProvider);
    if (members.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.debtsTitle,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (debts.isEmpty)
          Text(context.l10n.debtsSettled,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
        else
          for (final debt in debts)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.swap_horiz_rounded,
                    color: theme.colorScheme.primary),
                title: Text(context.l10n.debtLine(
                  members.tryById(debt.from)?.name ?? debt.from,
                  members.tryById(debt.to)?.name ?? debt.to,
                )),
                subtitle: Text(formatMoney(debt.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: TextButton(
                  onPressed: () => onSettle(debt),
                  child: Text(context.l10n.settleAction),
                ),
              ),
            ),
      ],
    );
  }
}
