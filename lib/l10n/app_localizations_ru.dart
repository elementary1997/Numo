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
  String get menuBudgets => 'Лимиты';

  @override
  String get menuRecurring => 'Регулярные';

  @override
  String get menuAccounts => 'Счета';

  @override
  String get menuRules => 'Автокатегории';

  @override
  String get menuImportCsv => 'Импорт выписок';

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
  String get chooseCsvPrompt =>
      'Выберите файл выписки — CSV, OFX, Excel (XLSX) или PDF Сбербанка';

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
  String get menuTheme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get accountTypeRegular => 'Обычный счёт';

  @override
  String get accountTypeDeposit => 'Вклад';

  @override
  String get rateLabel => 'Ставка, % годовых';

  @override
  String get openedLabel => 'Открыт';

  @override
  String get closesLabel => 'Закрытие';

  @override
  String projectedAtClose(String amount) {
    return 'К закрытию ≈ $amount';
  }

  @override
  String depositBadge(String rate, String date) {
    return 'Вклад · $rate% · до $date';
  }

  @override
  String get expensesForMonth => 'Расходы за месяц';

  @override
  String get incomeForMonth => 'Доходы за месяц';

  @override
  String get capitalStructure => 'Структура капитала';

  @override
  String get updatesGroup => 'Обновления';

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String get upToDate => 'У вас последняя версия';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get download => 'Скачать';

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get autoCheckUpdates => 'Проверять автоматически';

  @override
  String get accountBalanceLabel => 'Баланс';

  @override
  String get menuGoals => 'Цели';

  @override
  String get newGoal => 'Новая цель';

  @override
  String get editGoal => 'Изменить цель';

  @override
  String get targetAmountLabel => 'Целевая сумма, ₽';

  @override
  String get deadlineLabel => 'Срок';

  @override
  String get topUp => 'Пополнить';

  @override
  String get topUpAmount => 'Сумма пополнения, ₽';

  @override
  String savedOfTarget(String saved, String target) {
    return '$saved из $target';
  }

  @override
  String perMonthNeeded(String amount) {
    return '≈ $amount в месяц, чтобы успеть к сроку';
  }

  @override
  String get goalReached => 'Цель достигнута!';

  @override
  String get goalsEmptyHint =>
      'Отпуск, подушка безопасности, новая техника — задайте цель и отмечайте пополнения, а Numo посчитает прогресс и нужный темп.';

  @override
  String get deleteGoal => 'Удалить цель';

  @override
  String get menuAi => 'AI-аналитика';

  @override
  String get insightsTitle => 'Инсайты';

  @override
  String get aiSectionTitle => 'AI-разбор';

  @override
  String get aiExplainer =>
      'Подключите провайдера — Claude (Anthropic), Cloud.ru или локальную модель через LM Studio — и получите разбор финансов: паттерны, риски и конкретные советы. Сводные данные отправляются только по вашей команде; с LM Studio всё остаётся на вашем компьютере.';

  @override
  String get aiSetKey => 'Указать API-ключ';

  @override
  String get aiKeyLabel => 'API-ключ Anthropic';

  @override
  String get aiModelLabel => 'Модель';

  @override
  String get aiRun => 'Сделать разбор';

  @override
  String get aiConsentTitle => 'Отправить данные?';

  @override
  String get aiConsentBody =>
      'В Anthropic API уйдёт сводка: суммы по категориям и месяцам, балансы счетов и бюджеты. Заметки к операциям не отправляются. Запрос выполняется с вашим ключом.';

  @override
  String get aiSend => 'Отправить';

  @override
  String aiError(String error) {
    return 'Не получилось: $error';
  }

  @override
  String insSavingsRate(String percent) {
    return 'Вы откладываете $percent% дохода в этом месяце';
  }

  @override
  String insOverspend(String amount) {
    return 'Расходы превышают доходы на $amount';
  }

  @override
  String insTopCategory(String category, String amount, String percent) {
    return 'Крупнейшая категория — $category: $amount ($percent% расходов)';
  }

  @override
  String insCategoryUp(String category, String percent) {
    return '$category: траты выросли на $percent% к прошлому месяцу';
  }

  @override
  String insCategoryDown(String category, String percent) {
    return '$category: траты снизились на $percent% к прошлому месяцу';
  }

  @override
  String insRunRate(String daily, String projected) {
    return 'Средний темп — $daily в день; к концу месяца выйдет ≈ $projected';
  }

  @override
  String insBiggestTx(String title, String amount) {
    return 'Самая крупная трата: $title — $amount';
  }

  @override
  String get insBudgetsOk => 'Все лимиты соблюдены';

  @override
  String insBudgetsOver(int count) {
    return 'Лимитов превышено: $count';
  }

  @override
  String get accountTypeCard => 'Карта';

  @override
  String get accountTypeCash => 'Наличные';

  @override
  String get accountTypeSavings => 'Накопительный';

  @override
  String get aiProviderLabel => 'Провайдер';

  @override
  String get aiEndpointLabel => 'Endpoint';

  @override
  String get aiKeyGenericLabel => 'API-ключ';

  @override
  String get pdfParseFailed =>
      'Не удалось распознать PDF — выгрузите из банка CSV или Excel';

  @override
  String get wipeDataTitle => 'Стереть все данные';

  @override
  String get wipeDataBody =>
      'Будут удалены все операции, бюджеты, цели, правила и регулярные платежи; категории и счета вернутся к начальным. Это действие необратимо. Продолжить?';

  @override
  String get wipeDataDone => 'Данные стёрты';

  @override
  String get wipe => 'Стереть';

  @override
  String get biometricsButton => 'Войти по биометрии';

  @override
  String get biometricsReason => 'Разблокировать Numo';

  @override
  String get biometricsTitle => 'Вход по биометрии';

  @override
  String get biometricsSubtitle =>
      'Touch ID, Face ID или отпечаток — вместе с PIN-кодом';

  @override
  String get biometricsNeedPin =>
      'Сначала установите PIN-код — биометрия работает вместе с ним';

  @override
  String get biometricsEnabledToast => 'Биометрия включена';

  @override
  String get biometricsDisabledToast => 'Биометрия отключена';

  @override
  String get biometricsErrorTitle => 'Биометрия недоступна';

  @override
  String get biometricsNotEnrolled =>
      'Биометрия не настроена в системе. Добавьте отпечаток или Face ID в системных настройках и попробуйте снова.';

  @override
  String get biometricsNotAvailable =>
      'На этом устройстве нет поддерживаемой биометрии.';

  @override
  String get biometricsLockedOut =>
      'Биометрия временно заблокирована — войдите системным паролем и попробуйте снова.';

  @override
  String biometricsFailed(String message) {
    return 'Не удалось проверить биометрию: $message';
  }

  @override
  String whatsNewTitle(String version) {
    return 'Что нового в $version';
  }

  @override
  String get ok => 'Понятно';

  @override
  String get updateCheckFailed =>
      'Не удалось проверить обновления — проверьте доступ к сети';

  @override
  String get goalAccountLabel => 'Счёт цели';

  @override
  String get topUpFromAccount => 'Списать со счёта';

  @override
  String get currencyNoRate =>
      'Нет курса для конвертации — выберите валюту счёта или подождите загрузки курсов';

  @override
  String convertedFrom(String amount, String symbol) {
    return '$amount $symbol по курсу';
  }

  @override
  String get personalizationGroup => 'Персонализация';

  @override
  String get accentColorTitle => 'Акцентный цвет';

  @override
  String get dataGroup => 'Данные и безопасность';

  @override
  String get statementsFolderTitle => 'Папка выписок';

  @override
  String get statementsFolderExplainer =>
      'Укажите папку, куда сохраняете выписки из банков — Numo при запуске сам найдёт новые файлы и предложит импорт.';

  @override
  String statementFound(String name) {
    return 'Найдена новая выписка: $name';
  }

  @override
  String get importAction => 'Импортировать';

  @override
  String get uiScaleTitle => 'Масштаб интерфейса';

  @override
  String get scaleCompact => 'Компактный';

  @override
  String get scaleDefault => 'Стандартный';

  @override
  String get scaleLarge => 'Крупный';

  @override
  String get scaleXLarge => 'Очень крупный';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get updating => 'Скачивание обновления…';

  @override
  String get updateRestartNote => 'Приложение закроется и перезапустится само';

  @override
  String get updateFailed =>
      'Не удалось обновиться автоматически — откройте страницу релиза';

  @override
  String get openPage => 'Открыть страницу';

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

  @override
  String get statsConvertedByCbr =>
      'Валютные операции пересчитаны в рубли по курсу ЦБ';

  @override
  String statsNoRateFor(String currencies) {
    return 'Нет курса для $currencies — эти суммы посчитаны как рубли';
  }

  @override
  String get backupNotJson => 'Файл не является корректным JSON';

  @override
  String get backupNotNumo => 'Это не файл бэкапа Numo';

  @override
  String backupTooNew(int version) {
    return 'Бэкап создан более новой версией приложения (v$version)';
  }

  @override
  String get backupCorrupted => 'Файл бэкапа повреждён';

  @override
  String get menuShared => 'Общий счёт';

  @override
  String get sharedTitle => 'Общий счёт';

  @override
  String get sharedIntro =>
      'Общие счета и операции по ним обмениваются через папку в вашем облаке: каждый участник пишет свой файл, данные сливаются по времени изменения.';

  @override
  String get sharedFolderLabel => 'Папка обмена';

  @override
  String get sharedNoFolder => 'Папка не выбрана';

  @override
  String get sharedChooseFolder => 'Выбрать папку';

  @override
  String get sharedForgetFolder => 'Отключить';

  @override
  String get sharedFolderHint =>
      'Дайте второму участнику доступ к этой же папке в облаке и попросите указать её в своём Numo';

  @override
  String get sharedMyName => 'Моё имя';

  @override
  String get sharedMembers => 'Участники';

  @override
  String get sharedAddMember => 'Добавить человека';

  @override
  String get sharedMemberNameLabel => 'Имя';

  @override
  String get sharedNoMembers => 'Пока только вы';

  @override
  String get sharedSyncNow => 'Синхронизировать сейчас';

  @override
  String sharedPulled(int count) {
    return 'Принято изменений: $count';
  }

  @override
  String get sharedNothingNew => 'Новых изменений нет';

  @override
  String sharedLastSync(String when) {
    return 'Последняя сверка: $when';
  }

  @override
  String get sharedNeverSynced => 'Сверки ещё не было';

  @override
  String get sharedAccountToggle => 'Общий счёт';

  @override
  String get sharedAccountHint =>
      'Операции по этому счёту уедут в папку обмена и станут видны участникам';

  @override
  String sharedAuthor(String name) {
    return 'Внёс: $name';
  }

  @override
  String get sharedWebUnsupported =>
      'На веб-версии общие счета недоступны — нет доступа к папкам';

  @override
  String get sharedRemoveMemberTitle => 'Удалить участника?';

  @override
  String get sharedRemoveMemberBody =>
      'Операции, которые он внёс, останутся — исчезнет только подпись';

  @override
  String get removeAction => 'Удалить';

  @override
  String updateDidNotApply(String version) {
    return 'Обновление до $version не установилось';
  }

  @override
  String get updateNoWriteAccess =>
      'Нет прав на запись в папку, где стоит Numo. Скачайте новую версию со страницы релиза и распакуйте её сами — или перенесите приложение в свою папку пользователя.';
}
