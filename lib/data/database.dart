import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Строки операций. Доменная модель (`Tx`) остаётся отдельной —
/// таблица только про хранение.
class TransactionRows extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get accountId => text().withDefault(const Constant('main'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Счета: наличные, карты, вклады. У каждого своя валюта.
/// У вкладов заполнены ставка и даты открытия/закрытия.
class AccountRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get iconKey => text()();
  IntColumn get color => integer()();
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get kind => text().withDefault(const Constant('regular'))();
  RealColumn get rate => real().nullable()();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get closesAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Строки категорий (`TxCategory`).
class CategoryRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get iconKey => text()();
  IntColumn get color => integer()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Месячные лимиты трат по категориям. Лимит один и действует
/// каждый месяц; отсутствие строки = бюджета на категорию нет.
class BudgetRows extends Table {
  TextColumn get categoryId => text()();
  RealColumn get monthlyLimit => real()();

  @override
  Set<Column<Object>> get primaryKey => {categoryId};
}

/// Правила регулярных операций: раз в месяц в заданный день.
/// День больше длины месяца прижимается к последнему дню.
class RecurringRows extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get dayOfMonth => integer()();
  DateTimeColumn get startDate => dateTime()();

  /// По какую дату включительно правило уже материализовано —
  /// операции создаются только после неё, поэтому удалённые
  /// пользователем сгенерированные операции не возрождаются.
  DateTimeColumn get appliedThrough => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Цели накоплений: прогресс к целевой сумме, опциональный срок.
class GoalRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get iconKey => text()();
  IntColumn get color => integer()();
  RealColumn get targetAmount => real()();
  RealColumn get savedAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();

  /// Счёт, на котором лежат деньги цели; пополнения делают перевод
  /// на него с выбранного счёта-источника.
  TextColumn get accountId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Правила автокатегоризации: подстрока в описании → категория.
class CategoryRuleRows extends Table {
  TextColumn get id => text()();
  TextColumn get pattern => text()();
  TextColumn get categoryId => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [
  TransactionRows,
  CategoryRows,
  BudgetRows,
  RecurringRows,
  AccountRows,
  CategoryRuleRows,
  GoalRows,
])
class NumoDatabase extends _$NumoDatabase {
  /// Продакшн-конструктор открывает файл `numo` через drift_flutter;
  /// в тестах передаётся in-memory executor.
  NumoDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(budgetRows);
          }
          if (from < 3) {
            await m.createTable(recurringRows);
          }
          if (from < 4) {
            await m.createTable(accountRows);
            await m.addColumn(transactionRows, transactionRows.accountId);
          }
          if (from < 5) {
            await m.createTable(categoryRuleRows);
          }
          if (from < 6) {
            await m.addColumn(accountRows, accountRows.kind);
            await m.addColumn(accountRows, accountRows.rate);
            await m.addColumn(accountRows, accountRows.openedAt);
            await m.addColumn(accountRows, accountRows.closesAt);
          }
          if (from < 7) {
            await m.createTable(goalRows);
          }
          if (from < 8) {
            await m.addColumn(goalRows, goalRows.accountId);
          }
        },
      );

  static QueryExecutor _open() => driftDatabase(
        name: 'numo',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}
