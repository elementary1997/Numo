import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/recurring_repository.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/recurring.dart';
import 'package:numo/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NumoDatabase db;
  late TransactionsRepository txRepo;
  late RecurringRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    db = NumoDatabase(NativeDatabase.memory());
    txRepo = await TransactionsRepository.open(db);
    repo = await RecurringRepository.open(db);
  });

  tearDown(() => db.close());

  RecurringRule rule({
    int day = 5,
    DateTime? start,
    double amount = 500,
  }) =>
      RecurringRule(
        id: 'r1',
        type: TxType.expense,
        amount: amount,
        categoryId: 'home',
        note: 'Подписка',
        dayOfMonth: day,
        startDate: start ?? DateTime(2026, 6),
      );

  test('материализует все наступившие месяцы с начала правила', () async {
    await repo.saveAll([rule()]);
    final created =
        await repo.materialize(txRepo, now: DateTime(2026, 8, 24));

    expect(created, 3); // 5 июня, 5 июля, 5 августа
    final dates = txRepo.loadAll().map((t) => t.date).toList();
    expect(dates, contains(DateTime(2026, 6, 5)));
    expect(dates, contains(DateTime(2026, 8, 5)));
  });

  test('день 31 прижимается к последнему дню короткого месяца', () async {
    await repo.saveAll([rule(day: 31, start: DateTime(2026, 2))]);
    await repo.materialize(txRepo, now: DateTime(2026, 3, 31));

    final dates = txRepo.loadAll().map((t) => t.date).toList();
    expect(dates, contains(DateTime(2026, 2, 28)));
    expect(dates, contains(DateTime(2026, 3, 31)));
  });

  test('ещё не наступившая в этом месяце дата не создаётся', () async {
    await repo.saveAll([rule(day: 28, start: DateTime(2026, 8))]);
    final created =
        await repo.materialize(txRepo, now: DateTime(2026, 8, 24));
    expect(created, 0);
  });

  test('удалённая пользователем операция не возрождается', () async {
    await repo.saveAll([rule()]);
    await repo.materialize(txRepo, now: DateTime(2026, 8, 24));
    expect(txRepo.loadAll(), hasLength(3));

    // Пользователь удалил августовскую операцию.
    await txRepo.saveAll(
        txRepo.loadAll().where((t) => t.date.month != 8).toList());

    final reopened = await RecurringRepository.open(db);
    final created =
        await reopened.materialize(txRepo, now: DateTime(2026, 8, 25));
    expect(created, 0);
    expect(txRepo.loadAll(), hasLength(2));
  });

  test('повторная материализация идемпотентна', () async {
    await repo.saveAll([rule()]);
    await repo.materialize(txRepo, now: DateTime(2026, 8, 24));
    final again = await repo.materialize(txRepo, now: DateTime(2026, 8, 24));
    expect(again, 0);
    expect(txRepo.loadAll(), hasLength(3));
  });
}
