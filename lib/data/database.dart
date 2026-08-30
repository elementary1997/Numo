import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Строки операций. Доменная модель (`Tx`) остаётся отдельной —
/// таблица только про хранение.
///
/// Индексы — под то, как лента и статистика читают данные: по дате
/// (лента, период, месяц), по счёту (баланс счёта) и по надгробиям
/// (живые операции против удалённых).
@TableIndex(name: 'tx_date', columns: {#date})
@TableIndex(name: 'tx_account', columns: {#accountId})
@TableIndex(name: 'tx_deleted', columns: {#deletedAt})
class TransactionRows extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Заметка в нижнем регистре — по ней ищет лента. Отдельная колонка
  /// нужна потому, что SQLite-функция lower() понижает только ASCII:
  /// «Пятёрочка» она бы оставила как есть, и поиск стал бы
  /// регистрозависимым для кириллицы.
  TextColumn get noteLower => text().withDefault(const Constant(''))();
  TextColumn get accountId => text().withDefault(const Constant('main'))();

  /// Время последнего изменения и «надгробие» удаления — по ним
  /// сливаются данные участников общего счёта (ADR-0014).
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Участник, внёсший операцию.
  TextColumn get authorId => text().nullable()();

  /// Доли участников в трате, JSON `{"memberId": вес}`; null — трата
  /// не делится. Лежит в самой операции, чтобы уезжать в общий файл
  /// и сливаться вместе с ней (ADR-0014).
  TextColumn get split => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Участники общих счетов: люди, с которыми ведётся общий бюджет.
/// Ровно один помечен `isMe` — владелец этого устройства.
class MemberRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();

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

  /// Общий счёт: уезжает в папку обмена и сливается с данными
  /// других участников (ADR-0014).
  BoolColumn get shared => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

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

/// Журнал импортов выписок: какой файл, когда и сколько операций.
class ImportRows extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  DateTimeColumn get importedAt => dateTime()();
  IntColumn get opsCount => integer()();

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
  ImportRows,
  MemberRows,
])
class NumoDatabase extends _$NumoDatabase {
  /// Продакшн-конструктор открывает файл `numo` через drift_flutter;
  /// в тестах передаётся in-memory executor.
  NumoDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 13;

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
          if (from < 9) {
            await m.createTable(importRows);
          }
          if (from < 10) {
            // Общие счета (ADR-0014): отметки изменения, надгробия
            // удалений, автор операции и справочник участников.
            await m.addColumn(transactionRows, transactionRows.updatedAt);
            await m.addColumn(transactionRows, transactionRows.deletedAt);
            await m.addColumn(transactionRows, transactionRows.authorId);
            await m.addColumn(accountRows, accountRows.shared);
            await m.addColumn(accountRows, accountRows.updatedAt);
            await m.createTable(memberRows);
          }
          if (from < 11) {
            // Индексы под выборки ленты и балансов. Создаются после
            // миграции 10: tx_deleted ссылается на deleted_at, которой
            // до неё в таблице нет.
            await m.create(Index('tx_date',
                'CREATE INDEX IF NOT EXISTS tx_date ON transaction_rows (date)'));
            await m.create(Index('tx_account',
                'CREATE INDEX IF NOT EXISTS tx_account ON transaction_rows (account_id)'));
            await m.create(Index('tx_deleted',
                'CREATE INDEX IF NOT EXISTS tx_deleted ON transaction_rows (deleted_at)'));
          }
          if (from < 12) {
            // Поисковая колонка; существующие строки нормализует
            // репозиторий при открытии — SQL этого не умеет.
            await m.addColumn(transactionRows, transactionRows.noteLower);
          }
          if (from < 13) {
            // Разделение трат по долям (v1.13).
            await m.addColumn(transactionRows, transactionRows.split);
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
