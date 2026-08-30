import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Сверка общих счетов (ADR-0014): забрать файлы других участников,
/// слить их данные с локальными и выложить свой файл.
/// Возвращает число применённых чужих изменений.
Future<int> syncSharedAccounts(WidgetRef ref) async {
  final sync = ref.read(sharedSyncProvider);
  final me = ref.read(myMemberProvider);
  if (!sync.enabled || me == null) return 0;

  final snapshot = await sync.pull(myMemberId: me.id);
  var applied = 0;
  if (!snapshot.isEmpty) {
    applied += await ref
        .read(membersProvider.notifier)
        .mergeAll(snapshot.members);
    applied += await ref
        .read(accountsProvider.notifier)
        .mergeAll(snapshot.accounts);
    // Категории — до операций, иначе чужая операция на миг окажется
    // в «Другое».
    await ref
        .read(categoriesProvider.notifier)
        .mergeMissing(snapshot.categories);
    applied += await ref
        .read(transactionsProvider.notifier)
        .mergeAll(snapshot.transactions);
  }

  final data = collectSharedData(ref.read, ref.read(repositoryProvider));
  if (data != null) {
    await sync.publish(
      me: data.me,
      accounts: data.accounts,
      transactions: data.transactions,
      categories: data.categories,
    );
  }
  return applied;
}
