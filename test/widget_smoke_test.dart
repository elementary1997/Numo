import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/budgets_repository.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/recurring_repository.dart';
import 'package:numo/data/rules_repository.dart';
import 'package:numo/data/security_repository.dart';
import 'package:numo/data/sync_service.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/goals_repository.dart';
import 'package:numo/data/imports_repository.dart';
import 'package:numo/data/members_repository.dart';
import 'package:numo/data/shared_sync.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/main.dart';
import 'package:numo/models/member.dart';
import 'package:numo/models/transaction.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void useMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 930);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<Widget> buildApp({List<Tx> transactions = const []}) async {
  SharedPreferences.setMockInitialValues({
    'numo.transactions.migrated-to-drift.v1': true,
  });
  final db = NumoDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final repo = await TransactionsRepository.open(db);
  if (transactions.isNotEmpty) await repo.saveAll(transactions);
  final categoriesRepo = await CategoriesRepository.open(db);
  final budgetsRepo = await BudgetsRepository.open(db);
  final recurringRepo = await RecurringRepository.open(db);
  final accountsRepo = await AccountsRepository.open(db);
  final rulesRepo = await RulesRepository.open(db);
  final goalsRepo = await GoalsRepository.open(db);
  final importsRepo = await ImportsRepository.open(db);
  final securityRepo = await SecurityRepository.open();
  final membersRepo = await MembersRepository.open(db);
  final syncService = await SyncService.open();
  final sharedSync = await SharedSyncService.open();
  return ProviderScope(
    overrides: [
      // Тесты закреплены за русской локалью — проверяемые строки русские.
      localeOverrideProvider.overrideWith((ref) => 'ru'),
      securityRepositoryProvider.overrideWithValue(securityRepo),
      syncServiceProvider.overrideWithValue(syncService),
      membersRepositoryProvider.overrideWithValue(membersRepo),
      sharedSyncProvider.overrideWithValue(sharedSync),
      repositoryProvider.overrideWithValue(repo),
      categoriesRepositoryProvider.overrideWithValue(categoriesRepo),
      budgetsRepositoryProvider.overrideWithValue(budgetsRepo),
      recurringRepositoryProvider.overrideWithValue(recurringRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
      rulesRepositoryProvider.overrideWithValue(rulesRepo),
      goalsRepositoryProvider.overrideWithValue(goalsRepo),
      importsRepositoryProvider.overrideWithValue(importsRepo),
    ],
    child: const NumoApp(),
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('ru');
  });

  final sampleTxs = [
    Tx(
      id: 't1',
      type: TxType.expense,
      amount: 1200,
      categoryId: 'groceries',
      date: DateTime.now(),
      note: 'Пятёрочка',
    ),
    Tx(
      id: 't2',
      type: TxType.income,
      amount: 50000,
      categoryId: 'salary',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  testWidgets('дашборд показывает баланс и последние операции',
      (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp(transactions: sampleTxs));
    await tester.pumpAndSettle();

    expect(find.text('Numo'), findsOneWidget);
    expect(find.text('Общий баланс'), findsOneWidget);
    // 50 000 − 1 200 = 48 800 ₽ (после завершения анимации счётчика)
    expect(find.textContaining('48'), findsWidgets);
    expect(find.text('Продукты'), findsWidgets);
  });

  testWidgets('поиск в ленте операций фильтрует по заметке', (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp(transactions: sampleTxs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Операции'));
    await tester.pumpAndSettle();

    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Поиск по заметкам и категориям'),
        'Пятёрочка');
    await tester.pumpAndSettle();

    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsNothing);
  });

  testWidgets('новая операция добавляется через sheet', (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Сумма 250 на кастомной клавиатуре (pump после каждого тапа —
    // текст суммы и клавиша с той же цифрой не должны совпадать).
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('0').last);
    await tester.pump();

    await tester.tap(find.text('Продукты'));
    await tester.pump();

    await tester.ensureVisible(find.text('Добавить расход'));
    await tester.tap(find.text('Добавить расход'));
    await tester.pumpAndSettle();

    // Sheet закрылся, операция видна в «последних» на дашборде.
    expect(find.text('Добавить расход'), findsNothing);
    expect(find.text('Продукты'), findsWidgets);
    expect(find.textContaining('250'), findsWidgets);
  });

  testWidgets('редактирование: тап по операции открывает предзаполненный sheet',
      (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp(transactions: sampleTxs));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Продукты').first);
    await tester.pumpAndSettle();

    expect(find.text('Сохранить изменения'), findsOneWidget);
    expect(find.textContaining('1200', findRichText: true), findsWidgets);
  });

  testWidgets('экран общего счёта: участник добавляется и виден в списке',
      (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Меню'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Общий счёт').last);
    await tester.pumpAndSettle();

    expect(find.text('Пока только вы'), findsOneWidget);

    // Кнопка ведёт в диалог кода приглашения; оттуда — ручной ввод.
    await tester.tap(find.text('Добавить человека'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ввести имя вручную'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Аня');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Аня'), findsOneWidget);
    expect(find.text('Пока только вы'), findsNothing);
  });

  testWidgets('участник добавляется по коду приглашения', (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Меню'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Общий счёт').last);
    await tester.pumpAndSettle();

    const her = Member(
        id: 'her-code-1', name: 'Аня', color: Color(0xFF3DDC97));
    await tester.tap(find.text('Добавить человека'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, her.inviteCode);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Добавить человека'));
    await tester.pumpAndSettle();

    expect(find.text('Аня'), findsOneWidget);
  });

  testWidgets('негодный код приглашения объясняет ошибку', (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Меню'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Общий счёт').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Добавить человека'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'просто текст');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Добавить человека'));
    await tester.pumpAndSettle();

    expect(find.text('Это не похоже на код приглашения Numo'),
        findsOneWidget);
    expect(find.text('Пока только вы'), findsOneWidget);
  });
}
