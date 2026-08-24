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

@DriftDatabase(tables: [TransactionRows, CategoryRows, BudgetRows])
class NumoDatabase extends _$NumoDatabase {
  /// Продакшн-конструктор открывает файл `numo` через drift_flutter;
  /// в тестах передаётся in-memory executor.
  NumoDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(budgetRows);
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
