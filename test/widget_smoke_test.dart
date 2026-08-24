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
import 'package:numo/data/repository.dart';
import 'package:numo/main.dart';
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
  final securityRepo = await SecurityRepository.open();
  final syncService = await SyncService.open();
  return ProviderScope(
    overrides: [
      securityRepositoryProvider.overrideWithValue(securityRepo),
      syncServiceProvider.overrideWithValue(syncService),
      repositoryProvider.overrideWithValue(repo),
      categoriesRepositoryProvider.overrideWithValue(categoriesRepo),
      budgetsRepositoryProvider.overrideWithValue(budgetsRepo),
      recurringRepositoryProvider.overrideWithValue(recurringRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
      rulesRepositoryProvider.overrideWithValue(rulesRepo),
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

    // Сумма 250 на кастомной клавиатуре.
    await tester.tap(find.text('2'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
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
}
