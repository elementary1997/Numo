// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navOverview => 'Обзор';

  @override
  String get navTransactions => 'Операции';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get menuTooltip => 'Меню';

  @override
  String get menuCategories => 'Категории';

  @override
  String get menuBudgets => 'Бюджеты';

  @override
  String get menuRecurring => 'Регулярные';

  @override
  String get menuAccounts => 'Счета';

  @override
  String get menuRules => 'Автокатегории';

  @override
  String get menuImportCsv => 'Импорт CSV';

  @override
  String get menuExportCsv => 'Экспорт отчёта CSV';

  @override
  String get menuSecurity => 'Защита (PIN)';

  @override
  String get menuSync => 'Синхронизация';

  @override
  String get menuBackup => 'Бэкап (JSON)';

  @override
  String get menuRestore => 'Восстановить из бэкапа';

  @override
  String get totalBalance => 'Общий баланс';

  @override
  String totalBalanceExcluding(String currencies) {
    return 'Общий баланс (без $currencies)';
  }

  @override
  String get income => 'Доходы';

  @override
  String get expenses => 'Расходы';

  @override
  String get spendingStructure => 'Структура трат';

  @override
  String get recentTransactions => 'Последние операции';

  @override
  String get emptyAddFirst => 'Пока пусто — добавьте первую операцию';

  @override
  String get forMonth => 'За месяц';

  @override
  String get safeToSpendToday => 'Безопасно тратить сегодня';

  @override
  String get limitExceededChip => 'Лимит превышен';

  @override
  String get nearLimitChip => 'Близко к лимиту';

  @override
  String get searchHint => 'Поиск по заметкам и категориям';

  @override
  String get filterAll => 'Все';

  @override
  String get period => 'Период';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get noTransactions => 'Операций нет';

  @override
  String get transactionDeleted => 'Операция удалена';

  @override
  String get undo => 'Вернуть';

  @override
  String get savedThisMonth => 'Накоплено за месяц';

  @override
  String get overspendTitle => 'Перерасход';

  @override
  String get expensesByDay => 'Расходы по дням';

  @override
  String get topCategories => 'Топ категорий';

  @override
  String get noExpensesThisMonth => 'За этот месяц расходов нет';

  @override
  String get capital90Days => 'Капитал, 90 дней';

  @override
  String get expense => 'Расход';

  @override
  String get incomeSingular => 'Доход';

  @override
  String get transfer => 'Перевод';

  @override
  String get note => 'Заметка';

  @override
  String get newChip => 'Новая';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get addExpense => 'Добавить расход';

  @override
  String get addIncome => 'Добавить доход';

  @override
  String limitExceededToast(String category, String spent, String limit) {
    return 'Лимит «$category» превышен: $spent из $limit';
  }

  @override
  String get editCategory => 'Изменить категорию';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get nameLabel => 'Название';

  @override
  String get iconLabel => 'Иконка';

  @override
  String get colorLabel => 'Цвет';

  @override
  String get create => 'Создать';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get inArchive => 'В архиве';

  @override
  String get toArchive => 'В архив';

  @override
  String get fromArchive => 'Вернуть из архива';

  @override
  String get archiveSection => 'Архив';

  @override
  String get budgetsEmptyHint =>
      'Задайте месячный лимит хотя бы одной категории — появятся прогресс и подсказка, сколько можно тратить в день.';

  @override
  String get withLimit => 'С лимитом';

  @override
  String get withoutLimit => 'Без лимита';

  @override
  String spentOf(String spent, String limit) {
    return '$spent из $limit';
  }

  @override
  String get monthlyLimitLabel => 'Лимит на месяц, ₽';

  @override
  String get monthlyLimitHint => 'Например, 25000';

  @override
  String get removeLimit => 'Убрать лимит';

  @override
  String get newRule => 'Новое правило';

  @override
  String get editRule => 'Изменить правило';

  @override
  String get recurringEmptyHint =>
      'Подписки, аренда, зарплата — операции, которые повторяются каждый месяц, могут создаваться сами.';

  @override
  String get ruleDeletedToast =>
      'Правило удалено. Созданные операции остались.';

  @override
  String everyMonthOnDay(int day) {
    return 'Каждый месяц, $day-го числа';
  }

  @override
  String get amountRub => 'Сумма, ₽';

  @override
  String get dayLabel => 'День';

  @override
  String dayN(int day) {
    return '$day-е';
  }

  @override
  String get ruleNameHint => 'Название (например, «Аренда»)';

  @override
  String get newAccount => 'Новый счёт';

  @override
  String get editAccount => 'Изменить счёт';

  @override
  String get transferBetweenAccounts => 'Перевод между счетами';

  @override
  String get currencyLabel => 'Валюта';

  @override
  String get fromAccount => 'Со счёта';

  @override
  String get toAccount => 'На счёт';

  @override
  String get amountLabel => 'Сумма';

  @override
  String amountInCurrency(String symbol) {
    return 'Сумма, $symbol';
  }

  @override
  String creditedInCurrency(String symbol) {
    return 'Зачислится, $symbol';
  }

  @override
  String get currenciesDifferHint =>
      'Валюты счетов различаются — укажите обе суммы';

  @override
  String get transferButton => 'Перевести';

  @override
  String get importStatementTitle => 'Импорт выписки';

  @override
  String get chooseCsvPrompt => 'Выберите CSV-файл выписки из банка';

  @override
  String get chooseFile => 'Выбрать файл';

  @override
  String get fileEmptyToast => 'Файл пуст или не похож на CSV';

  @override
  String get columnsLabel => 'Колонки';

  @override
  String get colDate => 'Дата';

  @override
  String get colAmount => 'Сумма';

  @override
  String get colDescription => 'Описание';

  @override
  String get accountLabel => 'Счёт';

  @override
  String get unsignedIsExpense => 'Суммы без знака — это расходы';

  @override
  String get unsignedIsExpenseHint =>
      'Включите, если в выписке нет минусов у трат';

  @override
  String importSummary(int importable, int duplicates, int skipped) {
    return 'Будет импортировано: $importable · дубликаты: $duplicates · нераспознано: $skipped';
  }

  @override
  String moreRows(int count) {
    return '… и ещё $count строк';
  }

  @override
  String importButton(int count) {
    return 'Импортировать $count операций';
  }

  @override
  String importedToast(int count) {
    return 'Импортировано операций: $count';
  }

  @override
  String columnN(int n) {
    return 'Колонка $n';
  }

  @override
  String get noneOption => '— нет —';

  @override
  String get skippedRow => 'пропуск';

  @override
  String get duplicateRow => 'дубль';

  @override
  String get rulesApply => 'Применить';

  @override
  String get noMatchesToast => 'Совпадений не нашлось';

  @override
  String reclassifiedToast(int count) {
    return 'Переклассифицировано операций: $count';
  }

  @override
  String get ruleChip => 'Правило';

  @override
  String get rulesEmptyHint =>
      'Например: «ПЯТЕРОЧКА → Продукты». Правила срабатывают при импорте выписок, а кнопкой «Применить» — и на уже существующих операциях.';

  @override
  String get patternLabel => 'Подстрока в описании';

  @override
  String get patternHint => 'ПЯТЕРОЧКА';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get lockedTitle => 'Numo заблокирован';

  @override
  String get enterPin => 'Введите PIN';

  @override
  String get wrongPinRetry => 'Неверный PIN, попробуйте ещё раз';

  @override
  String get newPinTitle => 'Новый PIN (4–6 цифр)';

  @override
  String get repeatPinTitle => 'Повторите PIN';

  @override
  String get pinMismatchToast => 'PIN не совпал — не сохранён';

  @override
  String get pinSetToast => 'PIN установлен';

  @override
  String get securityTitle => 'Защита приложения';

  @override
  String get changePin => 'Сменить PIN';

  @override
  String get disablePin => 'Отключить PIN';

  @override
  String get currentPinTitle => 'Текущий PIN';

  @override
  String get wrongPinToast => 'Неверный PIN';

  @override
  String get pinDisabledToast => 'PIN отключён';

  @override
  String get pinChangedToast => 'PIN изменён';

  @override
  String get next => 'Далее';

  @override
  String get syncWebUnavailable =>
      'На web синхронизация недоступна — используйте бэкап (JSON)';

  @override
  String get syncTitle => 'Синхронизация';

  @override
  String syncExplainer(String file) {
    return 'Укажите папку, которую синхронизирует ваше облако (Яндекс.Диск, Dropbox, Syncthing…). Numo будет держать там файл $file и подхватывать изменения с других устройств.';
  }

  @override
  String syncFolder(String path) {
    return 'Папка: $path';
  }

  @override
  String syncLastWrite(String time) {
    return 'Последняя запись: $time';
  }

  @override
  String get disable => 'Отключить';

  @override
  String get close => 'Закрыть';

  @override
  String get chooseFolder => 'Выбрать папку';

  @override
  String get changeFolder => 'Сменить папку';

  @override
  String get syncDisabledToast => 'Синхронизация отключена';

  @override
  String get syncEnabledToast => 'Синхронизация включена, данные записаны';

  @override
  String get syncNewerTitle => 'Данные с другого устройства';

  @override
  String syncNewerBody(String time, int count) {
    return 'В папке синхронизации есть данные новее локальных (от $time): $count операций. Заменить локальные данные?';
  }

  @override
  String get keepMine => 'Оставить свои';

  @override
  String get accept => 'Принять';

  @override
  String get onb1Title => 'Знай, куда уходят деньги';

  @override
  String get onb1Text =>
      'Быстрое добавление трат, наглядная структура расходов и аналитика по месяцам. Для начала уже добавлены демо-данные — их можно просто удалить.';

  @override
  String get onb2Title => 'Планируй, а не вспоминай';

  @override
  String get onb2Text =>
      'Бюджеты по категориям с подсказкой «сколько можно тратить сегодня», регулярные платежи создаются сами, выписки из банка импортируются из CSV.';

  @override
  String get onb3Title => 'Данные — только твои';

  @override
  String get onb3Text =>
      'Всё хранится на устройстве, без серверов и аккаунтов. PIN-код, бэкапы одним файлом и синхронизация через твоё собственное облако.';

  @override
  String get skip => 'Пропустить';

  @override
  String get start => 'Начать';

  @override
  String get backupSavedToast => 'Бэкап сохранён';

  @override
  String get exportUnavailableToast =>
      'Экспорт в файл недоступен на этой платформе';

  @override
  String get csvSavedToast => 'CSV сохранён';

  @override
  String get restoreTitle => 'Восстановить из бэкапа?';

  @override
  String restoreBody(int txCount, int catCount) {
    return 'Текущие данные будут полностью заменены: $txCount операций и $catCount категорий из файла.';
  }

  @override
  String get replace => 'Заменить';

  @override
  String get dataRestoredToast => 'Данные восстановлены';

  @override
  String get menuLanguage => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get addTransaction => 'Новая операция';

  @override
  String get csvHeaderDate => 'Дата';

  @override
  String get csvHeaderType => 'Тип';

  @override
  String get csvHeaderAmount => 'Сумма';

  @override
  String get csvHeaderCurrency => 'Валюта';

  @override
  String get csvHeaderCategory => 'Категория';

  @override
  String get csvHeaderAccount => 'Счёт';

  @override
  String get csvHeaderNote => 'Заметка';
}
