import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Лента читает операции страницами из базы: фильтрует, ищет и
/// сортирует SQLite, а не приложение полным проходом по списку.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NumoDatabase db;
  late TransactionsRepository repo;

  Tx tx(
    String id, {
    required int day,
    double amount = 100,
    TxType type = TxType.expense,
    String note = '',
    String categoryId = 'groceries',
    String accountId = 'main',
  }) =>
      Tx(
        id: id,
        type: type,
        amount: amount,
        categoryId: categoryId,
        date: DateTime(2026, 8, day),
        note: note,
        accountId: accountId,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    db = NumoDatabase(NativeDatabase.memory());
    repo = await TransactionsRepository.open(db, seedDemo: false);
    await repo.upsertAll([
      tx('a', day: 1, note: 'Пятёрочка у дома'),
      tx('b', day: 5, note: 'YANDEX TAXI', categoryId: 'transport'),
      tx('c', day: 10, amount: 145000, type: TxType.income, note: 'Зарплата',
          categoryId: 'salary'),
      tx('d', day: 20, note: 'ПЯТЁРОЧКА центр', accountId: 'cash'),
    ]);
  });

  tearDown(() => db.close());

  test('страница отдаёт свежие операции первыми', () async {
    final page = await repo.page(limit: 2);
    expect(page.map((t) => t.id), ['d', 'c']);

    final next = await repo.page(limit: 2, offset: 2);
    expect(next.map((t) => t.id), ['b', 'a']);
  });

  test('поиск не зависит от регистра и работает с кириллицей', () async {
    // SQLite-функция lower() кириллицу не понижает — поэтому в базе
    // лежит отдельная нормализованная колонка.
    expect((await repo.page(query: 'пятёрочка')).map((t) => t.id),
        ['d', 'a']);
    expect((await repo.page(query: 'ПЯТЁРОЧКА')).map((t) => t.id),
        ['d', 'a']);
    expect((await repo.page(query: 'taxi')).map((t) => t.id), ['b']);
    expect(await repo.page(query: 'ничего такого'), isEmpty);
  });

  test('поиск подхватывает операции подошедшей категории', () async {
    // Экран передаёт id категорий, чьи названия совпали с запросом.
    final found = await repo.page(query: 'зарп', categoryIds: {'salary'});
    expect(found.map((t) => t.id), ['c']);
  });

  test('фильтры по типу, периоду и счёту', () async {
    expect((await repo.page(type: TxType.income)).map((t) => t.id), ['c']);
    expect(
        (await repo.page(
                from: DateTime(2026, 8, 5), to: DateTime(2026, 8, 10)))
            .map((t) => t.id),
        ['c', 'b']);
    expect((await repo.page(accountId: 'cash')).map((t) => t.id), ['d']);
  });

  test('удалённые операции в ленту не попадают', () async {
    await repo.removeById('d');
    final page = await repo.page();
    expect(page.map((t) => t.id), ['c', 'b', 'a']);
    // Надгробие при этом на месте — оно нужно слиянию общих счетов.
    expect(repo.allRows().where((t) => t.isDeleted).single.id, 'd');
  });

  test('заметки, записанные до появления поисковой колонки, находятся',
      () async {
    // Эмулируем строку из старой версии: поисковая колонка пустая.
    await db.customStatement(
        "UPDATE transaction_rows SET note_lower = '' WHERE id = 'a'");
    expect(await repo.page(query: 'пятёрочка у дома'), isEmpty);

    // Репозиторий дозаполняет её при открытии.
    final reopened = await TransactionsRepository.open(db, seedDemo: false);
    expect((await reopened.page(query: 'пятёрочка у дома')).single.id, 'a');
  });
}
