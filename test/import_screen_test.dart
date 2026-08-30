import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/categories_repository.dart';
import 'package:numo/data/csv.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/imports_repository.dart';
import 'package:numo/data/members_repository.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/data/rules_repository.dart';
import 'package:numo/l10n/app_localizations.dart';
import 'package:numo/screens/import_csv.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Импорт выписки — единственное место, где приложение массово создаёт
/// операции из чужих данных. Проверяется весь путь предпросмотр → база;
/// разбор самих файлов покрыт отдельно (csv_import_test, pdf_test).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('ru');
  });

  late NumoDatabase db;
  late TransactionsRepository txRepo;

  /// [fresh] `false` — переоткрыть экран на той же базе: так проверяется
  /// повторный импорт уже загруженной выписки.
  Future<Widget> buildImport(String csv, {bool fresh = true}) async {
    if (fresh) {
      SharedPreferences.setMockInitialValues({
        'numo.transactions.migrated-to-drift.v1': true,
      });
      db = NumoDatabase(NativeDatabase.memory());
      addTearDown(db.close);
    }
    txRepo = await TransactionsRepository.open(db, seedDemo: false);
    final categories = await CategoriesRepository.open(db);
    final accounts = await AccountsRepository.open(db);
    final rules = await RulesRepository.open(db);
    final imports = await ImportsRepository.open(db);
    final members = await MembersRepository.open(db);

    return ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(txRepo),
        categoriesRepositoryProvider.overrideWithValue(categories),
        accountsRepositoryProvider.overrideWithValue(accounts),
        rulesRepositoryProvider.overrideWithValue(rules),
        importsRepositoryProvider.overrideWithValue(imports),
        membersRepositoryProvider.overrideWithValue(members),
        localeOverrideProvider.overrideWith((ref) => 'ru'),
      ],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ImportCsvScreen(
          initialRows: Csv.parse(csv),
          initialFileName: 'statement.csv',
        ),
      ),
    );
  }

  ProviderContainer scopeOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ImportCsvScreen)));

  testWidgets('выписка доходит до базы и переживает перезагрузку',
      (tester) async {
    await tester.pumpWidget(await buildImport('Дата;Сумма;Описание\n'
        '01.08.2026;-350,50;ПЯТЕРОЧКА 1234\n'
        '02.08.2026;-1 200;YANDEX TAXI\n'
        '05.08.2026;145 000;ЗАРПЛАТА АВГУСТ\n'));
    await tester.pumpAndSettle();

    final scope = scopeOf(tester);
    expect(scope.read(transactionsProvider), isEmpty);
    // Колонки определились по заголовку — импортировать можно сразу.
    expect(find.text('Импортировать 3 операций'), findsOneWidget);

    await tester.tap(find.text('Импортировать 3 операций'));
    await tester.pumpAndSettle();

    final imported = scope.read(transactionsProvider);
    expect(imported, hasLength(3));
    expect(imported.map((t) => t.amount),
        containsAll(<double>[350.5, 1200, 145000]));

    final reopened = await TransactionsRepository.open(db, seedDemo: false);
    expect(reopened.loadAll(), hasLength(3));
  });

  testWidgets('мусорная строка видна в предпросмотре, но не импортируется',
      (tester) async {
    await tester.pumpWidget(await buildImport('Дата;Сумма;Описание\n'
        '01.08.2026;-350,50;ПЯТЕРОЧКА\n'
        'итого по счёту;;\n'));
    await tester.pumpAndSettle();

    expect(find.text('Импортировать 1 операций'), findsOneWidget);
    expect(find.text('Будет импортировано: 1 · дубликаты: 0 · нераспознано: 1'),
        findsOneWidget);

    await tester.tap(find.text('Импортировать 1 операций'));
    await tester.pumpAndSettle();
    expect(scopeOf(tester).read(transactionsProvider), hasLength(1));
  });

  testWidgets('одинаковые операции за день импортируются обе',
      (tester) async {
    await tester.pumpWidget(await buildImport('Дата;Сумма;Описание\n'
        '03.08.2026;-120;МЕТРО\n'
        '03.08.2026;-120;МЕТРО\n'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Импортировать 2 операций'));
    await tester.pumpAndSettle();
    expect(scopeOf(tester).read(transactionsProvider), hasLength(2));
  });

  testWidgets('повторный импорт того же файла ничего не задваивает',
      (tester) async {
    const csv = 'Дата;Сумма;Описание\n01.08.2026;-350,50;ПЯТЕРОЧКА\n';
    await tester.pumpWidget(await buildImport(csv));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Импортировать 1 операций'));
    await tester.pumpAndSettle();
    expect(scopeOf(tester).read(transactionsProvider), hasLength(1));

    // Тот же файл второй раз: строка помечена дубликатом, кнопки нет.
    // Пустой кадр между прогонами — иначе Flutter переиспользует
    // прежний State экрана вместе со старым предпросмотром.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(await buildImport(csv, fresh: false));
    await tester.pumpAndSettle();
    expect(find.text('Будет импортировано: 0 · дубликаты: 1 · нераспознано: 0'),
        findsOneWidget);
    // Кнопка на месте, но нажать нечего — импортировать нечего.
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Импортировать 0 операций'));
    expect(button.onPressed, isNull);
    expect(scopeOf(tester).read(transactionsProvider), hasLength(1));
  });
}
