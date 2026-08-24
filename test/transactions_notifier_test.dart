import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/transaction.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Tx tx(String id, double amount, {int day = 1}) => Tx(
      id: id,
      type: TxType.expense,
      amount: amount,
      categoryId: 'groceries',
      date: DateTime(2026, 8, day),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // Хранилище уже «сидировано», чтобы демо-данные не мешали тестам.
      'numo.seeded.v1': true,
    });
    final repo = await TransactionsRepository.open();
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() => container.dispose());

  test('add вставляет операцию и сохраняет сортировку по дате', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100, day: 5));
    await notifier.add(tx('b', 200, day: 10));
    await notifier.add(tx('c', 300, day: 1));

    final ids = container.read(transactionsProvider).map((t) => t.id).toList();
    expect(ids, ['b', 'a', 'c']);
  });

  test('update заменяет операцию по id и пересортировывает', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100, day: 5));
    await notifier.add(tx('b', 200, day: 10));

    await notifier.update(tx('a', 999, day: 20));

    final txs = container.read(transactionsProvider);
    expect(txs.first.id, 'a');
    expect(txs.first.amount, 999);
    expect(txs.length, 2);
  });

  test('изменения переживают перезагрузку из репозитория', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100));
    await notifier.update(tx('a', 555));

    final reloaded = await TransactionsRepository.open();
    expect(reloaded.loadAll().single.amount, 555);
  });

  test('remove удаляет операцию', () async {
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(tx('a', 100));
    await notifier.remove('a');
    expect(container.read(transactionsProvider), isEmpty);
  });
}
