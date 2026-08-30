import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @navOverview.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get navOverview;

  /// No description provided for @navTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Операции'**
  String get navTransactions;

  /// No description provided for @navAnalytics.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get navAnalytics;

  /// No description provided for @menuTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get menuTooltip;

  /// No description provided for @menuCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get menuCategories;

  /// No description provided for @menuBudgets.
  ///
  /// In ru, this message translates to:
  /// **'Лимиты'**
  String get menuBudgets;

  /// No description provided for @menuRecurring.
  ///
  /// In ru, this message translates to:
  /// **'Регулярные'**
  String get menuRecurring;

  /// No description provided for @menuAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Счета'**
  String get menuAccounts;

  /// No description provided for @menuRules.
  ///
  /// In ru, this message translates to:
  /// **'Автокатегории'**
  String get menuRules;

  /// No description provided for @menuImportCsv.
  ///
  /// In ru, this message translates to:
  /// **'Импорт выписок'**
  String get menuImportCsv;

  /// No description provided for @menuExportCsv.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт отчёта CSV'**
  String get menuExportCsv;

  /// No description provided for @menuSecurity.
  ///
  /// In ru, this message translates to:
  /// **'Защита (PIN)'**
  String get menuSecurity;

  /// No description provided for @menuSync.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get menuSync;

  /// No description provided for @menuBackup.
  ///
  /// In ru, this message translates to:
  /// **'Бэкап (JSON)'**
  String get menuBackup;

  /// No description provided for @menuRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из бэкапа'**
  String get menuRestore;

  /// No description provided for @totalBalance.
  ///
  /// In ru, this message translates to:
  /// **'Общий баланс'**
  String get totalBalance;

  /// No description provided for @totalBalanceExcluding.
  ///
  /// In ru, this message translates to:
  /// **'Общий баланс (без {currencies})'**
  String totalBalanceExcluding(String currencies);

  /// No description provided for @income.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get expenses;

  /// No description provided for @spendingStructure.
  ///
  /// In ru, this message translates to:
  /// **'Структура трат'**
  String get spendingStructure;

  /// No description provided for @recentTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Последние операции'**
  String get recentTransactions;

  /// No description provided for @emptyAddFirst.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто — добавьте первую операцию'**
  String get emptyAddFirst;

  /// No description provided for @forMonth.
  ///
  /// In ru, this message translates to:
  /// **'За месяц'**
  String get forMonth;

  /// No description provided for @safeToSpendToday.
  ///
  /// In ru, this message translates to:
  /// **'Безопасно тратить сегодня'**
  String get safeToSpendToday;

  /// No description provided for @limitExceededChip.
  ///
  /// In ru, this message translates to:
  /// **'Лимит превышен'**
  String get limitExceededChip;

  /// No description provided for @nearLimitChip.
  ///
  /// In ru, this message translates to:
  /// **'Близко к лимиту'**
  String get nearLimitChip;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по заметкам и категориям'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get filterAll;

  /// No description provided for @period.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get period;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @noTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Операций нет'**
  String get noTransactions;

  /// No description provided for @transactionDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Операция удалена'**
  String get transactionDeleted;

  /// No description provided for @undo.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть'**
  String get undo;

  /// No description provided for @savedThisMonth.
  ///
  /// In ru, this message translates to:
  /// **'Накоплено за месяц'**
  String get savedThisMonth;

  /// No description provided for @overspendTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перерасход'**
  String get overspendTitle;

  /// No description provided for @expensesByDay.
  ///
  /// In ru, this message translates to:
  /// **'Расходы по дням'**
  String get expensesByDay;

  /// No description provided for @topCategories.
  ///
  /// In ru, this message translates to:
  /// **'Топ категорий'**
  String get topCategories;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In ru, this message translates to:
  /// **'За этот месяц расходов нет'**
  String get noExpensesThisMonth;

  /// No description provided for @capital90Days.
  ///
  /// In ru, this message translates to:
  /// **'Капитал, 90 дней'**
  String get capital90Days;

  /// No description provided for @expense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get expense;

  /// No description provided for @incomeSingular.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get incomeSingular;

  /// No description provided for @transfer.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get transfer;

  /// No description provided for @note.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get note;

  /// No description provided for @newChip.
  ///
  /// In ru, this message translates to:
  /// **'Новая'**
  String get newChip;

  /// No description provided for @saveChanges.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить изменения'**
  String get saveChanges;

  /// No description provided for @addExpense.
  ///
  /// In ru, this message translates to:
  /// **'Добавить расход'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In ru, this message translates to:
  /// **'Добавить доход'**
  String get addIncome;

  /// No description provided for @limitExceededToast.
  ///
  /// In ru, this message translates to:
  /// **'Лимит «{category}» превышен: {spent} из {limit}'**
  String limitExceededToast(String category, String spent, String limit);

  /// No description provided for @editCategory.
  ///
  /// In ru, this message translates to:
  /// **'Изменить категорию'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In ru, this message translates to:
  /// **'Новая категория'**
  String get newCategory;

  /// No description provided for @nameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get nameLabel;

  /// No description provided for @iconLabel.
  ///
  /// In ru, this message translates to:
  /// **'Иконка'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get colorLabel;

  /// No description provided for @create.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get create;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @inArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архиве'**
  String get inArchive;

  /// No description provided for @toArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get toArchive;

  /// No description provided for @fromArchive.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть из архива'**
  String get fromArchive;

  /// No description provided for @archiveSection.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archiveSection;

  /// No description provided for @budgetsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Задайте месячный лимит хотя бы одной категории — появятся прогресс и подсказка, сколько можно тратить в день.'**
  String get budgetsEmptyHint;

  /// No description provided for @withLimit.
  ///
  /// In ru, this message translates to:
  /// **'С лимитом'**
  String get withLimit;

  /// No description provided for @withoutLimit.
  ///
  /// In ru, this message translates to:
  /// **'Без лимита'**
  String get withoutLimit;

  /// No description provided for @spentOf.
  ///
  /// In ru, this message translates to:
  /// **'{spent} из {limit}'**
  String spentOf(String spent, String limit);

  /// No description provided for @monthlyLimitLabel.
  ///
  /// In ru, this message translates to:
  /// **'Лимит на месяц, ₽'**
  String get monthlyLimitLabel;

  /// No description provided for @monthlyLimitHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, 25000'**
  String get monthlyLimitHint;

  /// No description provided for @removeLimit.
  ///
  /// In ru, this message translates to:
  /// **'Убрать лимит'**
  String get removeLimit;

  /// No description provided for @newRule.
  ///
  /// In ru, this message translates to:
  /// **'Новое правило'**
  String get newRule;

  /// No description provided for @editRule.
  ///
  /// In ru, this message translates to:
  /// **'Изменить правило'**
  String get editRule;

  /// No description provided for @recurringEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Подписки, аренда, зарплата — операции, которые повторяются каждый месяц, могут создаваться сами.'**
  String get recurringEmptyHint;

  /// No description provided for @ruleDeletedToast.
  ///
  /// In ru, this message translates to:
  /// **'Правило удалено. Созданные операции остались.'**
  String get ruleDeletedToast;

  /// No description provided for @everyMonthOnDay.
  ///
  /// In ru, this message translates to:
  /// **'Каждый месяц, {day}-го числа'**
  String everyMonthOnDay(int day);

  /// No description provided for @amountRub.
  ///
  /// In ru, this message translates to:
  /// **'Сумма, ₽'**
  String get amountRub;

  /// No description provided for @dayLabel.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get dayLabel;

  /// No description provided for @dayN.
  ///
  /// In ru, this message translates to:
  /// **'{day}-е'**
  String dayN(int day);

  /// No description provided for @ruleNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Название (например, «Аренда»)'**
  String get ruleNameHint;

  /// No description provided for @newAccount.
  ///
  /// In ru, this message translates to:
  /// **'Новый счёт'**
  String get newAccount;

  /// No description provided for @editAccount.
  ///
  /// In ru, this message translates to:
  /// **'Изменить счёт'**
  String get editAccount;

  /// No description provided for @transferBetweenAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Перевод между счетами'**
  String get transferBetweenAccounts;

  /// No description provided for @currencyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get currencyLabel;

  /// No description provided for @fromAccount.
  ///
  /// In ru, this message translates to:
  /// **'Со счёта'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In ru, this message translates to:
  /// **'На счёт'**
  String get toAccount;

  /// No description provided for @amountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get amountLabel;

  /// No description provided for @amountInCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Сумма, {symbol}'**
  String amountInCurrency(String symbol);

  /// No description provided for @creditedInCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Зачислится, {symbol}'**
  String creditedInCurrency(String symbol);

  /// No description provided for @currenciesDifferHint.
  ///
  /// In ru, this message translates to:
  /// **'Валюты счетов различаются — укажите обе суммы'**
  String get currenciesDifferHint;

  /// No description provided for @transferButton.
  ///
  /// In ru, this message translates to:
  /// **'Перевести'**
  String get transferButton;

  /// No description provided for @importStatementTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт выписки'**
  String get importStatementTitle;

  /// No description provided for @chooseCsvPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Выберите файл выписки — CSV, OFX, Excel (XLSX) или PDF Сбербанка'**
  String get chooseCsvPrompt;

  /// No description provided for @chooseFile.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать файл'**
  String get chooseFile;

  /// No description provided for @fileEmptyToast.
  ///
  /// In ru, this message translates to:
  /// **'Файл пуст или не похож на CSV'**
  String get fileEmptyToast;

  /// No description provided for @columnsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Колонки'**
  String get columnsLabel;

  /// No description provided for @colDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get colDate;

  /// No description provided for @colAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get colAmount;

  /// No description provided for @colDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get colDescription;

  /// No description provided for @accountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get accountLabel;

  /// No description provided for @unsignedIsExpense.
  ///
  /// In ru, this message translates to:
  /// **'Суммы без знака — это расходы'**
  String get unsignedIsExpense;

  /// No description provided for @unsignedIsExpenseHint.
  ///
  /// In ru, this message translates to:
  /// **'Включите, если в выписке нет минусов у трат'**
  String get unsignedIsExpenseHint;

  /// No description provided for @importSummary.
  ///
  /// In ru, this message translates to:
  /// **'Будет импортировано: {importable} · дубликаты: {duplicates} · нераспознано: {skipped}'**
  String importSummary(int importable, int duplicates, int skipped);

  /// No description provided for @moreRows.
  ///
  /// In ru, this message translates to:
  /// **'… и ещё {count} строк'**
  String moreRows(int count);

  /// No description provided for @importButton.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать {count} операций'**
  String importButton(int count);

  /// No description provided for @importedToast.
  ///
  /// In ru, this message translates to:
  /// **'Импортировано операций: {count}'**
  String importedToast(int count);

  /// No description provided for @importedFilesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уже импортированные файлы'**
  String get importedFilesTitle;

  /// No description provided for @showMoreCount.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё ({count})'**
  String showMoreCount(int count);

  /// No description provided for @columnN.
  ///
  /// In ru, this message translates to:
  /// **'Колонка {n}'**
  String columnN(int n);

  /// No description provided for @noneOption.
  ///
  /// In ru, this message translates to:
  /// **'— нет —'**
  String get noneOption;

  /// No description provided for @skippedRow.
  ///
  /// In ru, this message translates to:
  /// **'пропуск'**
  String get skippedRow;

  /// No description provided for @duplicateRow.
  ///
  /// In ru, this message translates to:
  /// **'дубль'**
  String get duplicateRow;

  /// No description provided for @rulesApply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get rulesApply;

  /// No description provided for @noMatchesToast.
  ///
  /// In ru, this message translates to:
  /// **'Совпадений не нашлось'**
  String get noMatchesToast;

  /// No description provided for @reclassifiedToast.
  ///
  /// In ru, this message translates to:
  /// **'Переклассифицировано операций: {count}'**
  String reclassifiedToast(int count);

  /// No description provided for @ruleChip.
  ///
  /// In ru, this message translates to:
  /// **'Правило'**
  String get ruleChip;

  /// No description provided for @rulesEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: «ПЯТЕРОЧКА → Продукты». Правила срабатывают при импорте выписок, а кнопкой «Применить» — и на уже существующих операциях.'**
  String get rulesEmptyHint;

  /// No description provided for @patternLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подстрока в описании'**
  String get patternLabel;

  /// No description provided for @patternHint.
  ///
  /// In ru, this message translates to:
  /// **'ПЯТЕРОЧКА'**
  String get patternHint;

  /// No description provided for @categoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get categoryLabel;

  /// No description provided for @lockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Numo заблокирован'**
  String get lockedTitle;

  /// No description provided for @enterPin.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN'**
  String get enterPin;

  /// No description provided for @wrongPinRetry.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN, попробуйте ещё раз'**
  String get wrongPinRetry;

  /// No description provided for @newPinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый PIN (4–6 цифр)'**
  String get newPinTitle;

  /// No description provided for @repeatPinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Повторите PIN'**
  String get repeatPinTitle;

  /// No description provided for @pinMismatchToast.
  ///
  /// In ru, this message translates to:
  /// **'PIN не совпал — не сохранён'**
  String get pinMismatchToast;

  /// No description provided for @pinSetToast.
  ///
  /// In ru, this message translates to:
  /// **'PIN установлен'**
  String get pinSetToast;

  /// No description provided for @securityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Защита приложения'**
  String get securityTitle;

  /// No description provided for @changePin.
  ///
  /// In ru, this message translates to:
  /// **'Сменить PIN'**
  String get changePin;

  /// No description provided for @disablePin.
  ///
  /// In ru, this message translates to:
  /// **'Отключить PIN'**
  String get disablePin;

  /// No description provided for @currentPinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Текущий PIN'**
  String get currentPinTitle;

  /// No description provided for @wrongPinToast.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN'**
  String get wrongPinToast;

  /// No description provided for @pinDisabledToast.
  ///
  /// In ru, this message translates to:
  /// **'PIN отключён'**
  String get pinDisabledToast;

  /// No description provided for @pinChangedToast.
  ///
  /// In ru, this message translates to:
  /// **'PIN изменён'**
  String get pinChangedToast;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @syncWebUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'На web синхронизация недоступна — используйте бэкап (JSON)'**
  String get syncWebUnavailable;

  /// No description provided for @syncTitle.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get syncTitle;

  /// No description provided for @syncExplainer.
  ///
  /// In ru, this message translates to:
  /// **'Укажите папку, которую синхронизирует ваше облако (Яндекс.Диск, Dropbox, Syncthing…). Numo будет держать там файл {file} и подхватывать изменения с других устройств.'**
  String syncExplainer(String file);

  /// No description provided for @syncFolder.
  ///
  /// In ru, this message translates to:
  /// **'Папка: {path}'**
  String syncFolder(String path);

  /// No description provided for @syncLastWrite.
  ///
  /// In ru, this message translates to:
  /// **'Последняя запись: {time}'**
  String syncLastWrite(String time);

  /// No description provided for @disable.
  ///
  /// In ru, this message translates to:
  /// **'Отключить'**
  String get disable;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @chooseFolder.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать папку'**
  String get chooseFolder;

  /// No description provided for @changeFolder.
  ///
  /// In ru, this message translates to:
  /// **'Сменить папку'**
  String get changeFolder;

  /// No description provided for @syncDisabledToast.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация отключена'**
  String get syncDisabledToast;

  /// No description provided for @syncEnabledToast.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация включена, данные записаны'**
  String get syncEnabledToast;

  /// No description provided for @syncNewerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Данные с другого устройства'**
  String get syncNewerTitle;

  /// No description provided for @syncNewerBody.
  ///
  /// In ru, this message translates to:
  /// **'В папке синхронизации есть данные новее локальных (от {time}): {count} операций. Заменить локальные данные?'**
  String syncNewerBody(String time, int count);

  /// No description provided for @keepMine.
  ///
  /// In ru, this message translates to:
  /// **'Оставить свои'**
  String get keepMine;

  /// No description provided for @accept.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get accept;

  /// No description provided for @onb1Title.
  ///
  /// In ru, this message translates to:
  /// **'Знай, куда уходят деньги'**
  String get onb1Title;

  /// No description provided for @onb1Text.
  ///
  /// In ru, this message translates to:
  /// **'Быстрое добавление трат, наглядная структура расходов и аналитика по месяцам. Для начала уже добавлены демо-данные — их можно просто удалить.'**
  String get onb1Text;

  /// No description provided for @onb2Title.
  ///
  /// In ru, this message translates to:
  /// **'Планируй, а не вспоминай'**
  String get onb2Title;

  /// No description provided for @onb2Text.
  ///
  /// In ru, this message translates to:
  /// **'Бюджеты по категориям с подсказкой «сколько можно тратить сегодня», регулярные платежи создаются сами, выписки из банка импортируются из CSV.'**
  String get onb2Text;

  /// No description provided for @onb3Title.
  ///
  /// In ru, this message translates to:
  /// **'Данные — только твои'**
  String get onb3Title;

  /// No description provided for @onb3Text.
  ///
  /// In ru, this message translates to:
  /// **'Всё хранится на устройстве, без серверов и аккаунтов. PIN-код, бэкапы одним файлом и синхронизация через твоё собственное облако.'**
  String get onb3Text;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @start.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get start;

  /// No description provided for @backupSavedToast.
  ///
  /// In ru, this message translates to:
  /// **'Бэкап сохранён'**
  String get backupSavedToast;

  /// No description provided for @exportUnavailableToast.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт в файл недоступен на этой платформе'**
  String get exportUnavailableToast;

  /// No description provided for @csvSavedToast.
  ///
  /// In ru, this message translates to:
  /// **'CSV сохранён'**
  String get csvSavedToast;

  /// No description provided for @restoreTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из бэкапа?'**
  String get restoreTitle;

  /// No description provided for @restoreBody.
  ///
  /// In ru, this message translates to:
  /// **'Текущие данные будут полностью заменены: {txCount} операций и {catCount} категорий из файла.'**
  String restoreBody(int txCount, int catCount);

  /// No description provided for @replace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get replace;

  /// No description provided for @dataRestoredToast.
  ///
  /// In ru, this message translates to:
  /// **'Данные восстановлены'**
  String get dataRestoredToast;

  /// No description provided for @menuLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get menuLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @menuSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get menuSettings;

  /// No description provided for @addTransaction.
  ///
  /// In ru, this message translates to:
  /// **'Новая операция'**
  String get addTransaction;

  /// No description provided for @menuTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get menuTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @accountTypeRegular.
  ///
  /// In ru, this message translates to:
  /// **'Обычный счёт'**
  String get accountTypeRegular;

  /// No description provided for @accountTypeDeposit.
  ///
  /// In ru, this message translates to:
  /// **'Вклад'**
  String get accountTypeDeposit;

  /// No description provided for @rateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ставка, % годовых'**
  String get rateLabel;

  /// No description provided for @openedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Открыт'**
  String get openedLabel;

  /// No description provided for @closesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Закрытие'**
  String get closesLabel;

  /// No description provided for @projectedAtClose.
  ///
  /// In ru, this message translates to:
  /// **'К закрытию ≈ {amount}'**
  String projectedAtClose(String amount);

  /// No description provided for @depositBadge.
  ///
  /// In ru, this message translates to:
  /// **'Вклад · {rate}% · до {date}'**
  String depositBadge(String rate, String date);

  /// No description provided for @expensesForMonth.
  ///
  /// In ru, this message translates to:
  /// **'Расходы за месяц'**
  String get expensesForMonth;

  /// No description provided for @incomeForMonth.
  ///
  /// In ru, this message translates to:
  /// **'Доходы за месяц'**
  String get incomeForMonth;

  /// No description provided for @capitalStructure.
  ///
  /// In ru, this message translates to:
  /// **'Структура капитала'**
  String get capitalStructure;

  /// No description provided for @updatesGroup.
  ///
  /// In ru, this message translates to:
  /// **'Обновления'**
  String get updatesGroup;

  /// No description provided for @checkUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновления'**
  String get checkUpdates;

  /// No description provided for @upToDate.
  ///
  /// In ru, this message translates to:
  /// **'У вас последняя версия'**
  String get upToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {version}'**
  String updateAvailable(String version);

  /// No description provided for @download.
  ///
  /// In ru, this message translates to:
  /// **'Скачать'**
  String get download;

  /// No description provided for @versionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String versionLabel(String version);

  /// No description provided for @autoCheckUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Проверять автоматически'**
  String get autoCheckUpdates;

  /// No description provided for @accountBalanceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get accountBalanceLabel;

  /// No description provided for @menuGoals.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get menuGoals;

  /// No description provided for @newGoal.
  ///
  /// In ru, this message translates to:
  /// **'Новая цель'**
  String get newGoal;

  /// No description provided for @editGoal.
  ///
  /// In ru, this message translates to:
  /// **'Изменить цель'**
  String get editGoal;

  /// No description provided for @targetAmountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Целевая сумма, ₽'**
  String get targetAmountLabel;

  /// No description provided for @deadlineLabel.
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get deadlineLabel;

  /// No description provided for @topUp.
  ///
  /// In ru, this message translates to:
  /// **'Пополнить'**
  String get topUp;

  /// No description provided for @topUpAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма пополнения, ₽'**
  String get topUpAmount;

  /// No description provided for @savedOfTarget.
  ///
  /// In ru, this message translates to:
  /// **'{saved} из {target}'**
  String savedOfTarget(String saved, String target);

  /// No description provided for @perMonthNeeded.
  ///
  /// In ru, this message translates to:
  /// **'≈ {amount} в месяц, чтобы успеть к сроку'**
  String perMonthNeeded(String amount);

  /// No description provided for @goalReached.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута!'**
  String get goalReached;

  /// No description provided for @goalsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Отпуск, подушка безопасности, новая техника — задайте цель и отмечайте пополнения, а Numo посчитает прогресс и нужный темп.'**
  String get goalsEmptyHint;

  /// No description provided for @deleteGoal.
  ///
  /// In ru, this message translates to:
  /// **'Удалить цель'**
  String get deleteGoal;

  /// No description provided for @menuAi.
  ///
  /// In ru, this message translates to:
  /// **'AI-аналитика'**
  String get menuAi;

  /// No description provided for @insightsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Инсайты'**
  String get insightsTitle;

  /// No description provided for @aiSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'AI-разбор'**
  String get aiSectionTitle;

  /// No description provided for @aiExplainer.
  ///
  /// In ru, this message translates to:
  /// **'Подключите провайдера — Claude (Anthropic), Cloud.ru или локальную модель через LM Studio — и получите разбор финансов: паттерны, риски и конкретные советы. Сводные данные отправляются только по вашей команде; с LM Studio всё остаётся на вашем компьютере.'**
  String get aiExplainer;

  /// No description provided for @aiSetKey.
  ///
  /// In ru, this message translates to:
  /// **'Указать API-ключ'**
  String get aiSetKey;

  /// No description provided for @aiKeyLabel.
  ///
  /// In ru, this message translates to:
  /// **'API-ключ Anthropic'**
  String get aiKeyLabel;

  /// No description provided for @aiModelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get aiModelLabel;

  /// No description provided for @aiRun.
  ///
  /// In ru, this message translates to:
  /// **'Сделать разбор'**
  String get aiRun;

  /// No description provided for @aiConsentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отправить данные?'**
  String get aiConsentTitle;

  /// No description provided for @aiConsentBody.
  ///
  /// In ru, this message translates to:
  /// **'В Anthropic API уйдёт сводка: суммы по категориям и месяцам, балансы счетов и бюджеты. Заметки к операциям не отправляются. Запрос выполняется с вашим ключом.'**
  String get aiConsentBody;

  /// No description provided for @aiSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get aiSend;

  /// No description provided for @aiError.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось: {error}'**
  String aiError(String error);

  /// No description provided for @insSavingsRate.
  ///
  /// In ru, this message translates to:
  /// **'Вы откладываете {percent}% дохода в этом месяце'**
  String insSavingsRate(String percent);

  /// No description provided for @insOverspend.
  ///
  /// In ru, this message translates to:
  /// **'Расходы превышают доходы на {amount}'**
  String insOverspend(String amount);

  /// No description provided for @insTopCategory.
  ///
  /// In ru, this message translates to:
  /// **'Крупнейшая категория — {category}: {amount} ({percent}% расходов)'**
  String insTopCategory(String category, String amount, String percent);

  /// No description provided for @insCategoryUp.
  ///
  /// In ru, this message translates to:
  /// **'{category}: траты выросли на {percent}% к прошлому месяцу'**
  String insCategoryUp(String category, String percent);

  /// No description provided for @insCategoryDown.
  ///
  /// In ru, this message translates to:
  /// **'{category}: траты снизились на {percent}% к прошлому месяцу'**
  String insCategoryDown(String category, String percent);

  /// No description provided for @insRunRate.
  ///
  /// In ru, this message translates to:
  /// **'Средний темп — {daily} в день; к концу месяца выйдет ≈ {projected}'**
  String insRunRate(String daily, String projected);

  /// No description provided for @insBiggestTx.
  ///
  /// In ru, this message translates to:
  /// **'Самая крупная трата: {title} — {amount}'**
  String insBiggestTx(String title, String amount);

  /// No description provided for @insBudgetsOk.
  ///
  /// In ru, this message translates to:
  /// **'Все лимиты соблюдены'**
  String get insBudgetsOk;

  /// No description provided for @insBudgetsOver.
  ///
  /// In ru, this message translates to:
  /// **'Лимитов превышено: {count}'**
  String insBudgetsOver(int count);

  /// No description provided for @accountTypeCard.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get accountTypeCard;

  /// No description provided for @accountTypeCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get accountTypeCash;

  /// No description provided for @accountTypeSavings.
  ///
  /// In ru, this message translates to:
  /// **'Накопительный'**
  String get accountTypeSavings;

  /// No description provided for @aiProviderLabel.
  ///
  /// In ru, this message translates to:
  /// **'Провайдер'**
  String get aiProviderLabel;

  /// No description provided for @aiEndpointLabel.
  ///
  /// In ru, this message translates to:
  /// **'Endpoint'**
  String get aiEndpointLabel;

  /// No description provided for @aiKeyGenericLabel.
  ///
  /// In ru, this message translates to:
  /// **'API-ключ'**
  String get aiKeyGenericLabel;

  /// No description provided for @pdfParseFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось распознать PDF — выгрузите из банка CSV или Excel'**
  String get pdfParseFailed;

  /// No description provided for @wipeDataTitle.
  ///
  /// In ru, this message translates to:
  /// **'Стереть все данные'**
  String get wipeDataTitle;

  /// No description provided for @wipeDataBody.
  ///
  /// In ru, this message translates to:
  /// **'Будут удалены все операции, бюджеты, цели, правила и регулярные платежи; категории и счета вернутся к начальным. Это действие необратимо. Продолжить?'**
  String get wipeDataBody;

  /// No description provided for @wipeDataDone.
  ///
  /// In ru, this message translates to:
  /// **'Данные стёрты'**
  String get wipeDataDone;

  /// No description provided for @wipe.
  ///
  /// In ru, this message translates to:
  /// **'Стереть'**
  String get wipe;

  /// No description provided for @biometricsButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти по биометрии'**
  String get biometricsButton;

  /// No description provided for @biometricsReason.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать Numo'**
  String get biometricsReason;

  /// No description provided for @biometricsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход по биометрии'**
  String get biometricsTitle;

  /// No description provided for @biometricsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Touch ID, Face ID или отпечаток — вместе с PIN-кодом'**
  String get biometricsSubtitle;

  /// No description provided for @biometricsNeedPin.
  ///
  /// In ru, this message translates to:
  /// **'Сначала установите PIN-код — биометрия работает вместе с ним'**
  String get biometricsNeedPin;

  /// No description provided for @biometricsEnabledToast.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия включена'**
  String get biometricsEnabledToast;

  /// No description provided for @biometricsDisabledToast.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия отключена'**
  String get biometricsDisabledToast;

  /// No description provided for @biometricsErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия недоступна'**
  String get biometricsErrorTitle;

  /// No description provided for @biometricsNotEnrolled.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия не настроена в системе. Добавьте отпечаток или Face ID в системных настройках и попробуйте снова.'**
  String get biometricsNotEnrolled;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In ru, this message translates to:
  /// **'На этом устройстве нет поддерживаемой биометрии.'**
  String get biometricsNotAvailable;

  /// No description provided for @biometricsLockedOut.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия временно заблокирована — войдите системным паролем и попробуйте снова.'**
  String get biometricsLockedOut;

  /// No description provided for @biometricsFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить биометрию: {message}'**
  String biometricsFailed(String message);

  /// No description provided for @whatsNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что нового в {version}'**
  String whatsNewTitle(String version);

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get ok;

  /// No description provided for @updateCheckFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить обновления — проверьте доступ к сети'**
  String get updateCheckFailed;

  /// No description provided for @goalAccountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Счёт цели'**
  String get goalAccountLabel;

  /// No description provided for @topUpFromAccount.
  ///
  /// In ru, this message translates to:
  /// **'Списать со счёта'**
  String get topUpFromAccount;

  /// No description provided for @currencyNoRate.
  ///
  /// In ru, this message translates to:
  /// **'Нет курса для конвертации — выберите валюту счёта или подождите загрузки курсов'**
  String get currencyNoRate;

  /// No description provided for @convertedFrom.
  ///
  /// In ru, this message translates to:
  /// **'{amount} {symbol} по курсу'**
  String convertedFrom(String amount, String symbol);

  /// No description provided for @personalizationGroup.
  ///
  /// In ru, this message translates to:
  /// **'Персонализация'**
  String get personalizationGroup;

  /// No description provided for @accentColorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Акцентный цвет'**
  String get accentColorTitle;

  /// No description provided for @dataGroup.
  ///
  /// In ru, this message translates to:
  /// **'Данные и безопасность'**
  String get dataGroup;

  /// No description provided for @statementsFolderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Папка выписок'**
  String get statementsFolderTitle;

  /// No description provided for @statementsFolderExplainer.
  ///
  /// In ru, this message translates to:
  /// **'Укажите папку, куда сохраняете выписки из банков — Numo при запуске сам найдёт новые файлы и предложит импорт.'**
  String get statementsFolderExplainer;

  /// No description provided for @statementFound.
  ///
  /// In ru, this message translates to:
  /// **'Найдена новая выписка: {name}'**
  String statementFound(String name);

  /// No description provided for @importAction.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать'**
  String get importAction;

  /// No description provided for @uiScaleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Масштаб интерфейса'**
  String get uiScaleTitle;

  /// No description provided for @scaleCompact.
  ///
  /// In ru, this message translates to:
  /// **'Компактный'**
  String get scaleCompact;

  /// No description provided for @scaleDefault.
  ///
  /// In ru, this message translates to:
  /// **'Стандартный'**
  String get scaleDefault;

  /// No description provided for @scaleLarge.
  ///
  /// In ru, this message translates to:
  /// **'Крупный'**
  String get scaleLarge;

  /// No description provided for @scaleXLarge.
  ///
  /// In ru, this message translates to:
  /// **'Очень крупный'**
  String get scaleXLarge;

  /// No description provided for @updateNow.
  ///
  /// In ru, this message translates to:
  /// **'Обновить сейчас'**
  String get updateNow;

  /// No description provided for @updating.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание обновления…'**
  String get updating;

  /// No description provided for @updateRestartNote.
  ///
  /// In ru, this message translates to:
  /// **'Приложение закроется и перезапустится само'**
  String get updateRestartNote;

  /// No description provided for @updateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновиться автоматически — откройте страницу релиза'**
  String get updateFailed;

  /// No description provided for @openPage.
  ///
  /// In ru, this message translates to:
  /// **'Открыть страницу'**
  String get openPage;

  /// No description provided for @csvHeaderDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get csvHeaderDate;

  /// No description provided for @csvHeaderType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get csvHeaderType;

  /// No description provided for @csvHeaderAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get csvHeaderAmount;

  /// No description provided for @csvHeaderCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get csvHeaderCurrency;

  /// No description provided for @csvHeaderCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get csvHeaderCategory;

  /// No description provided for @csvHeaderAccount.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get csvHeaderAccount;

  /// No description provided for @csvHeaderNote.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get csvHeaderNote;

  /// No description provided for @statsConvertedByCbr.
  ///
  /// In ru, this message translates to:
  /// **'Валютные операции пересчитаны в рубли по курсу ЦБ'**
  String get statsConvertedByCbr;

  /// No description provided for @statsNoRateFor.
  ///
  /// In ru, this message translates to:
  /// **'Нет курса для {currencies} — эти суммы посчитаны как рубли'**
  String statsNoRateFor(String currencies);

  /// No description provided for @backupNotJson.
  ///
  /// In ru, this message translates to:
  /// **'Файл не является корректным JSON'**
  String get backupNotJson;

  /// No description provided for @backupNotNumo.
  ///
  /// In ru, this message translates to:
  /// **'Это не файл бэкапа Numo'**
  String get backupNotNumo;

  /// No description provided for @backupTooNew.
  ///
  /// In ru, this message translates to:
  /// **'Бэкап создан более новой версией приложения (v{version})'**
  String backupTooNew(int version);

  /// No description provided for @backupCorrupted.
  ///
  /// In ru, this message translates to:
  /// **'Файл бэкапа повреждён'**
  String get backupCorrupted;

  /// No description provided for @menuShared.
  ///
  /// In ru, this message translates to:
  /// **'Общий счёт'**
  String get menuShared;

  /// No description provided for @sharedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Общий счёт'**
  String get sharedTitle;

  /// No description provided for @sharedIntro.
  ///
  /// In ru, this message translates to:
  /// **'Общие счета и операции по ним обмениваются через папку в вашем облаке: каждый участник пишет свой файл, данные сливаются по времени изменения.'**
  String get sharedIntro;

  /// No description provided for @sharedFolderLabel.
  ///
  /// In ru, this message translates to:
  /// **'Папка обмена'**
  String get sharedFolderLabel;

  /// No description provided for @sharedNoFolder.
  ///
  /// In ru, this message translates to:
  /// **'Папка не выбрана'**
  String get sharedNoFolder;

  /// No description provided for @sharedChooseFolder.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать папку'**
  String get sharedChooseFolder;

  /// No description provided for @sharedForgetFolder.
  ///
  /// In ru, this message translates to:
  /// **'Отключить'**
  String get sharedForgetFolder;

  /// No description provided for @sharedFolderHint.
  ///
  /// In ru, this message translates to:
  /// **'Дайте второму участнику доступ к этой же папке в облаке и попросите указать её в своём Numo'**
  String get sharedFolderHint;

  /// No description provided for @sharedMyName.
  ///
  /// In ru, this message translates to:
  /// **'Моё имя'**
  String get sharedMyName;

  /// No description provided for @sharedMembers.
  ///
  /// In ru, this message translates to:
  /// **'Участники'**
  String get sharedMembers;

  /// No description provided for @sharedAddMember.
  ///
  /// In ru, this message translates to:
  /// **'Добавить человека'**
  String get sharedAddMember;

  /// No description provided for @sharedMemberNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get sharedMemberNameLabel;

  /// No description provided for @sharedNoMembers.
  ///
  /// In ru, this message translates to:
  /// **'Пока только вы'**
  String get sharedNoMembers;

  /// No description provided for @sharedSyncNow.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать сейчас'**
  String get sharedSyncNow;

  /// No description provided for @sharedPulled.
  ///
  /// In ru, this message translates to:
  /// **'Принято изменений: {count}'**
  String sharedPulled(int count);

  /// No description provided for @sharedNothingNew.
  ///
  /// In ru, this message translates to:
  /// **'Новых изменений нет'**
  String get sharedNothingNew;

  /// No description provided for @sharedLastSync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя сверка: {when}'**
  String sharedLastSync(String when);

  /// No description provided for @sharedNeverSynced.
  ///
  /// In ru, this message translates to:
  /// **'Сверки ещё не было'**
  String get sharedNeverSynced;

  /// No description provided for @sharedAccountToggle.
  ///
  /// In ru, this message translates to:
  /// **'Общий счёт'**
  String get sharedAccountToggle;

  /// No description provided for @sharedAccountHint.
  ///
  /// In ru, this message translates to:
  /// **'Операции по этому счёту уедут в папку обмена и станут видны участникам'**
  String get sharedAccountHint;

  /// No description provided for @sharedAuthor.
  ///
  /// In ru, this message translates to:
  /// **'Внёс: {name}'**
  String sharedAuthor(String name);

  /// No description provided for @sharedWebUnsupported.
  ///
  /// In ru, this message translates to:
  /// **'На веб-версии общие счета недоступны — нет доступа к папкам'**
  String get sharedWebUnsupported;

  /// No description provided for @sharedRemoveMemberTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить участника?'**
  String get sharedRemoveMemberTitle;

  /// No description provided for @sharedRemoveMemberBody.
  ///
  /// In ru, this message translates to:
  /// **'Операции, которые он внёс, останутся — исчезнет только подпись'**
  String get sharedRemoveMemberBody;

  /// No description provided for @removeAction.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get removeAction;

  /// No description provided for @updateDidNotApply.
  ///
  /// In ru, this message translates to:
  /// **'Обновление до {version} не установилось'**
  String updateDidNotApply(String version);

  /// No description provided for @updateNoWriteAccess.
  ///
  /// In ru, this message translates to:
  /// **'Нет прав на запись в папку, где стоит Numo. Скачайте новую версию со страницы релиза и распакуйте её сами — или перенесите приложение в свою папку пользователя.'**
  String get updateNoWriteAccess;

  /// No description provided for @sharedMyCode.
  ///
  /// In ru, this message translates to:
  /// **'Мой код приглашения'**
  String get sharedMyCode;

  /// No description provided for @sharedMyCodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Передайте его близкому — он вставит код у себя, и вы увидите друг друга по именам. Доступ к операциям даёт не код, а общая папка.'**
  String get sharedMyCodeHint;

  /// No description provided for @sharedShowCode.
  ///
  /// In ru, this message translates to:
  /// **'Показать код'**
  String get sharedShowCode;

  /// No description provided for @sharedCopyCode.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get sharedCopyCode;

  /// No description provided for @sharedCodeCopied.
  ///
  /// In ru, this message translates to:
  /// **'Код скопирован'**
  String get sharedCodeCopied;

  /// No description provided for @sharedAddByCode.
  ///
  /// In ru, this message translates to:
  /// **'Добавить по коду'**
  String get sharedAddByCode;

  /// No description provided for @sharedCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код приглашения'**
  String get sharedCodeLabel;

  /// No description provided for @sharedCodeInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Это не похоже на код приглашения Numo'**
  String get sharedCodeInvalid;

  /// No description provided for @sharedCodeIsMine.
  ///
  /// In ru, this message translates to:
  /// **'Это ваш собственный код'**
  String get sharedCodeIsMine;

  /// No description provided for @sharedMemberAdded.
  ///
  /// In ru, this message translates to:
  /// **'{name} теперь в списке участников'**
  String sharedMemberAdded(String name);

  /// No description provided for @sharedAddManually.
  ///
  /// In ru, this message translates to:
  /// **'Ввести имя вручную'**
  String get sharedAddManually;

  /// No description provided for @updateBannerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {version}'**
  String updateBannerTitle(String version);

  /// No description provided for @updateBannerBody.
  ///
  /// In ru, this message translates to:
  /// **'Приложение обновится само: скачает сборку, закроется и запустится заново'**
  String get updateBannerBody;

  /// No description provided for @updateLater.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get updateLater;

  /// No description provided for @updateInstalledVersion.
  ///
  /// In ru, this message translates to:
  /// **'Установлена {version}'**
  String updateInstalledVersion(String version);

  /// No description provided for @updateAvailableShort.
  ///
  /// In ru, this message translates to:
  /// **'Доступна {version}'**
  String updateAvailableShort(String version);

  /// No description provided for @a11yPrevMonth.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий месяц'**
  String get a11yPrevMonth;

  /// No description provided for @a11yNextMonth.
  ///
  /// In ru, this message translates to:
  /// **'Следующий месяц'**
  String get a11yNextMonth;

  /// No description provided for @a11yDeleteRule.
  ///
  /// In ru, this message translates to:
  /// **'Удалить правило'**
  String get a11yDeleteRule;

  /// No description provided for @a11yRemoveMember.
  ///
  /// In ru, this message translates to:
  /// **'Удалить участника'**
  String get a11yRemoveMember;

  /// No description provided for @a11yExpenseAmount.
  ///
  /// In ru, this message translates to:
  /// **'Расход {amount}'**
  String a11yExpenseAmount(String amount);

  /// No description provided for @a11yIncomeAmount.
  ///
  /// In ru, this message translates to:
  /// **'Доход {amount}'**
  String a11yIncomeAmount(String amount);

  /// No description provided for @a11yDonutChart.
  ///
  /// In ru, this message translates to:
  /// **'Круговая диаграмма расходов по категориям'**
  String get a11yDonutChart;

  /// No description provided for @a11yDailyChart.
  ///
  /// In ru, this message translates to:
  /// **'Столбчатая диаграмма расходов по дням, максимум {amount}'**
  String a11yDailyChart(String amount);

  /// No description provided for @a11yCapitalChart.
  ///
  /// In ru, this message translates to:
  /// **'График капитала, сейчас {amount}'**
  String a11yCapitalChart(String amount);

  /// No description provided for @a11yBudgetProgress.
  ///
  /// In ru, this message translates to:
  /// **'{category}: потрачено {spent} из {limit}, {percent} процентов'**
  String a11yBudgetProgress(
    String category,
    String spent,
    String limit,
    String percent,
  );

  /// No description provided for @a11yGoalProgress.
  ///
  /// In ru, this message translates to:
  /// **'{title}: накоплено {saved} из {target}'**
  String a11yGoalProgress(String title, String saved, String target);

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Накануне регулярных платежей и при перерасходе бюджета'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsDenied.
  ///
  /// In ru, this message translates to:
  /// **'Система не дала разрешение на уведомления'**
  String get notificationsDenied;

  /// No description provided for @reminderPaymentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Завтра списание: {title}'**
  String reminderPaymentTitle(String title);

  /// No description provided for @reminderOverspentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет превышен'**
  String get reminderOverspentTitle;

  /// No description provided for @reminderOverspentBody.
  ///
  /// In ru, this message translates to:
  /// **'{category}: потрачено {spent} при лимите {limit}'**
  String reminderOverspentBody(String category, String spent, String limit);

  /// No description provided for @splitTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разделить трату'**
  String get splitTitle;

  /// No description provided for @splitHint.
  ///
  /// In ru, this message translates to:
  /// **'Отметьте, между кем делится: поровну'**
  String get splitHint;

  /// No description provided for @debtsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Кто кому должен'**
  String get debtsTitle;

  /// No description provided for @debtsSettled.
  ///
  /// In ru, this message translates to:
  /// **'Все в расчёте'**
  String get debtsSettled;

  /// No description provided for @debtLine.
  ///
  /// In ru, this message translates to:
  /// **'{from} → {to}'**
  String debtLine(String from, String to);

  /// No description provided for @settleAction.
  ///
  /// In ru, this message translates to:
  /// **'Погасить'**
  String get settleAction;

  /// No description provided for @settleNote.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт: {from} → {to}'**
  String settleNote(String from, String to);

  /// No description provided for @settleDone.
  ///
  /// In ru, this message translates to:
  /// **'Долг отмечен погашенным'**
  String get settleDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
