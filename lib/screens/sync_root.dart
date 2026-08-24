import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForNewer());
  }

  Future<void> _checkForNewer() async {
    final newer = await ref.read(syncServiceProvider).checkForNewer();
    if (newer == null || !mounted) return;
    final (data, exportedAt) = newer;

    final accept = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Данные с другого устройства'),
        content: Text(
          'В папке синхронизации есть данные новее локальных '
          '(от ${DateFormat('d MMM yyyy, HH:mm', 'ru').format(exportedAt)}): '
          '${data.transactions.length} операций. Заменить локальные данные?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Оставить свои'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Принять'),
          ),
        ],
      ),
    );
    if (accept != true) return;

    await ref.read(categoriesProvider.notifier).replaceAll(data.categories);
    await ref.read(accountsProvider.notifier).replaceAll(data.accounts);
    await ref.read(budgetsProvider.notifier).replaceAll(data.budgets);
    await ref.read(recurringProvider.notifier).replaceAll(data.recurring);
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
    return widget.child;
  }
}
