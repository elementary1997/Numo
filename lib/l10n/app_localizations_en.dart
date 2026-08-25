// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navOverview => 'Overview';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get menuCategories => 'Categories';

  @override
  String get menuBudgets => 'Limits';

  @override
  String get menuRecurring => 'Recurring';

  @override
  String get menuAccounts => 'Accounts';

  @override
  String get menuRules => 'Auto-categories';

  @override
  String get menuImportCsv => 'Import statements';

  @override
  String get menuExportCsv => 'Export CSV report';

  @override
  String get menuSecurity => 'Security (PIN)';

  @override
  String get menuSync => 'Sync';

  @override
  String get menuBackup => 'Backup (JSON)';

  @override
  String get menuRestore => 'Restore from backup';

  @override
  String get totalBalance => 'Total balance';

  @override
  String totalBalanceExcluding(String currencies) {
    return 'Total balance (excl. $currencies)';
  }

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get spendingStructure => 'Spending structure';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get emptyAddFirst => 'Nothing here yet — add your first transaction';

  @override
  String get forMonth => 'This month';

  @override
  String get safeToSpendToday => 'Safe to spend today';

  @override
  String get limitExceededChip => 'Over limit';

  @override
  String get nearLimitChip => 'Near limit';

  @override
  String get searchHint => 'Search notes and categories';

  @override
  String get filterAll => 'All';

  @override
  String get period => 'Period';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get undo => 'Undo';

  @override
  String get savedThisMonth => 'Saved this month';

  @override
  String get overspendTitle => 'Overspend';

  @override
  String get expensesByDay => 'Expenses by day';

  @override
  String get topCategories => 'Top categories';

  @override
  String get noExpensesThisMonth => 'No expenses this month';

  @override
  String get capital90Days => 'Net worth, 90 days';

  @override
  String get expense => 'Expense';

  @override
  String get incomeSingular => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get note => 'Note';

  @override
  String get newChip => 'New';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addIncome => 'Add income';

  @override
  String limitExceededToast(String category, String spent, String limit) {
    return '“$category” limit exceeded: $spent of $limit';
  }

  @override
  String get editCategory => 'Edit category';

  @override
  String get newCategory => 'New category';

  @override
  String get nameLabel => 'Name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get inArchive => 'Archived';

  @override
  String get toArchive => 'Archive';

  @override
  String get fromArchive => 'Unarchive';

  @override
  String get archiveSection => 'Archive';

  @override
  String get budgetsEmptyHint =>
      'Set a monthly limit for at least one category to see progress and a daily spending hint.';

  @override
  String get withLimit => 'With a limit';

  @override
  String get withoutLimit => 'No limit';

  @override
  String spentOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get monthlyLimitLabel => 'Monthly limit, ₽';

  @override
  String get monthlyLimitHint => 'For example, 25000';

  @override
  String get removeLimit => 'Remove limit';

  @override
  String get newRule => 'New rule';

  @override
  String get editRule => 'Edit rule';

  @override
  String get recurringEmptyHint =>
      'Subscriptions, rent, salary — transactions that repeat every month can create themselves.';

  @override
  String get ruleDeletedToast =>
      'Rule deleted. Created transactions were kept.';

  @override
  String everyMonthOnDay(int day) {
    return 'Every month on day $day';
  }

  @override
  String get amountRub => 'Amount, ₽';

  @override
  String get dayLabel => 'Day';

  @override
  String dayN(int day) {
    return '$day';
  }

  @override
  String get ruleNameHint => 'Name (for example, “Rent”)';

  @override
  String get newAccount => 'New account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get transferBetweenAccounts => 'Transfer between accounts';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get fromAccount => 'From account';

  @override
  String get toAccount => 'To account';

  @override
  String get amountLabel => 'Amount';

  @override
  String amountInCurrency(String symbol) {
    return 'Amount, $symbol';
  }

  @override
  String creditedInCurrency(String symbol) {
    return 'Credited, $symbol';
  }

  @override
  String get currenciesDifferHint =>
      'Accounts use different currencies — enter both amounts';

  @override
  String get transferButton => 'Transfer';

  @override
  String get importStatementTitle => 'Statement import';

  @override
  String get chooseCsvPrompt =>
      'Choose a statement file — CSV, OFX, Excel (XLSX) or Sberbank PDF';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get fileEmptyToast => 'The file is empty or not a CSV';

  @override
  String get columnsLabel => 'Columns';

  @override
  String get colDate => 'Date';

  @override
  String get colAmount => 'Amount';

  @override
  String get colDescription => 'Description';

  @override
  String get accountLabel => 'Account';

  @override
  String get unsignedIsExpense => 'Unsigned amounts are expenses';

  @override
  String get unsignedIsExpenseHint =>
      'Turn on if the statement has no minus signs on spending';

  @override
  String importSummary(int importable, int duplicates, int skipped) {
    return 'To import: $importable · duplicates: $duplicates · unrecognized: $skipped';
  }

  @override
  String moreRows(int count) {
    return '… and $count more rows';
  }

  @override
  String importButton(int count) {
    return 'Import $count transactions';
  }

  @override
  String importedToast(int count) {
    return 'Transactions imported: $count';
  }

  @override
  String get importedFilesTitle => 'Imported files';

  @override
  String showMoreCount(int count) {
    return 'Show more ($count)';
  }

  @override
  String columnN(int n) {
    return 'Column $n';
  }

  @override
  String get noneOption => '— none —';

  @override
  String get skippedRow => 'skipped';

  @override
  String get duplicateRow => 'duplicate';

  @override
  String get rulesApply => 'Apply';

  @override
  String get noMatchesToast => 'No matches found';

  @override
  String reclassifiedToast(int count) {
    return 'Transactions reclassified: $count';
  }

  @override
  String get ruleChip => 'Rule';

  @override
  String get rulesEmptyHint =>
      'For example: “WALMART → Groceries”. Rules run during statement import, and the Apply button runs them on existing transactions.';

  @override
  String get patternLabel => 'Substring in the description';

  @override
  String get patternHint => 'WALMART';

  @override
  String get categoryLabel => 'Category';

  @override
  String get lockedTitle => 'Numo is locked';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get wrongPinRetry => 'Wrong PIN, try again';

  @override
  String get newPinTitle => 'New PIN (4–6 digits)';

  @override
  String get repeatPinTitle => 'Repeat PIN';

  @override
  String get pinMismatchToast => 'PINs don\'t match — not saved';

  @override
  String get pinSetToast => 'PIN set';

  @override
  String get securityTitle => 'App security';

  @override
  String get changePin => 'Change PIN';

  @override
  String get disablePin => 'Disable PIN';

  @override
  String get currentPinTitle => 'Current PIN';

  @override
  String get wrongPinToast => 'Wrong PIN';

  @override
  String get pinDisabledToast => 'PIN disabled';

  @override
  String get pinChangedToast => 'PIN changed';

  @override
  String get next => 'Next';

  @override
  String get syncWebUnavailable =>
      'Sync is unavailable on the web — use JSON backup instead';

  @override
  String get syncTitle => 'Sync';

  @override
  String syncExplainer(String file) {
    return 'Choose a folder that your own cloud keeps in sync (Dropbox, Syncthing…). Numo will keep the $file file there and pick up changes from other devices.';
  }

  @override
  String syncFolder(String path) {
    return 'Folder: $path';
  }

  @override
  String syncLastWrite(String time) {
    return 'Last write: $time';
  }

  @override
  String get disable => 'Disable';

  @override
  String get close => 'Close';

  @override
  String get chooseFolder => 'Choose folder';

  @override
  String get changeFolder => 'Change folder';

  @override
  String get syncDisabledToast => 'Sync disabled';

  @override
  String get syncEnabledToast => 'Sync enabled, data written';

  @override
  String get syncNewerTitle => 'Data from another device';

  @override
  String syncNewerBody(String time, int count) {
    return 'The sync folder has data newer than local (from $time): $count transactions. Replace local data?';
  }

  @override
  String get keepMine => 'Keep mine';

  @override
  String get accept => 'Accept';

  @override
  String get onb1Title => 'Know where the money goes';

  @override
  String get onb1Text =>
      'Quick expense entry, a clear spending structure and monthly analytics. Demo data is preloaded to look around — just delete it.';

  @override
  String get onb2Title => 'Plan, don\'t recall';

  @override
  String get onb2Text =>
      'Per-category budgets with a “safe to spend today” hint, recurring payments that create themselves, and CSV bank statement import.';

  @override
  String get onb3Title => 'Your data stays yours';

  @override
  String get onb3Text =>
      'Everything lives on your device — no servers, no accounts. PIN lock, one-file backups and sync through your own cloud.';

  @override
  String get skip => 'Skip';

  @override
  String get start => 'Get started';

  @override
  String get backupSavedToast => 'Backup saved';

  @override
  String get exportUnavailableToast =>
      'File export is unavailable on this platform';

  @override
  String get csvSavedToast => 'CSV saved';

  @override
  String get restoreTitle => 'Restore from backup?';

  @override
  String restoreBody(int txCount, int catCount) {
    return 'Current data will be fully replaced with $txCount transactions and $catCount categories from the file.';
  }

  @override
  String get replace => 'Replace';

  @override
  String get dataRestoredToast => 'Data restored';

  @override
  String get menuLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get menuSettings => 'Settings';

  @override
  String get addTransaction => 'New transaction';

  @override
  String get menuTheme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accountTypeRegular => 'Regular account';

  @override
  String get accountTypeDeposit => 'Deposit';

  @override
  String get rateLabel => 'Rate, % per year';

  @override
  String get openedLabel => 'Opened';

  @override
  String get closesLabel => 'Closes';

  @override
  String projectedAtClose(String amount) {
    return 'At close ≈ $amount';
  }

  @override
  String depositBadge(String rate, String date) {
    return 'Deposit · $rate% · until $date';
  }

  @override
  String get expensesForMonth => 'Expenses this month';

  @override
  String get incomeForMonth => 'Income this month';

  @override
  String get capitalStructure => 'Portfolio structure';

  @override
  String get updatesGroup => 'Updates';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get upToDate => 'You are on the latest version';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get download => 'Download';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get autoCheckUpdates => 'Check automatically';

  @override
  String get accountBalanceLabel => 'Balance';

  @override
  String get menuGoals => 'Goals';

  @override
  String get newGoal => 'New goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get targetAmountLabel => 'Target amount, ₽';

  @override
  String get deadlineLabel => 'Deadline';

  @override
  String get topUp => 'Top up';

  @override
  String get topUpAmount => 'Top-up amount, ₽';

  @override
  String savedOfTarget(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String perMonthNeeded(String amount) {
    return '≈ $amount per month to make the deadline';
  }

  @override
  String get goalReached => 'Goal reached!';

  @override
  String get goalsEmptyHint =>
      'A vacation, an emergency fund, new hardware — set a goal, log top-ups, and Numo tracks progress and the pace you need.';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String get menuAi => 'AI insights';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get aiSectionTitle => 'AI review';

  @override
  String get aiExplainer =>
      'Connect a provider — Claude (Anthropic), Cloud.ru or a local model via LM Studio — to get a finance review: patterns, risks and concrete advice. Summary data is sent only when you ask; with LM Studio everything stays on your machine.';

  @override
  String get aiSetKey => 'Set API key';

  @override
  String get aiKeyLabel => 'Anthropic API key';

  @override
  String get aiModelLabel => 'Model';

  @override
  String get aiRun => 'Run review';

  @override
  String get aiConsentTitle => 'Send data?';

  @override
  String get aiConsentBody =>
      'A summary will be sent to the Anthropic API: category and monthly totals, account balances and budgets. Transaction notes are not sent. The request uses your key.';

  @override
  String get aiSend => 'Send';

  @override
  String aiError(String error) {
    return 'Failed: $error';
  }

  @override
  String insSavingsRate(String percent) {
    return 'You are saving $percent% of this month\'s income';
  }

  @override
  String insOverspend(String amount) {
    return 'Expenses exceed income by $amount';
  }

  @override
  String insTopCategory(String category, String amount, String percent) {
    return 'Biggest category — $category: $amount ($percent% of spending)';
  }

  @override
  String insCategoryUp(String category, String percent) {
    return '$category: spending up $percent% vs last month';
  }

  @override
  String insCategoryDown(String category, String percent) {
    return '$category: spending down $percent% vs last month';
  }

  @override
  String insRunRate(String daily, String projected) {
    return 'Average pace — $daily per day; on track for ≈ $projected this month';
  }

  @override
  String insBiggestTx(String title, String amount) {
    return 'Largest expense: $title — $amount';
  }

  @override
  String get insBudgetsOk => 'All budgets within limits';

  @override
  String insBudgetsOver(int count) {
    return 'Budgets exceeded: $count';
  }

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get aiProviderLabel => 'Provider';

  @override
  String get aiEndpointLabel => 'Endpoint';

  @override
  String get aiKeyGenericLabel => 'API key';

  @override
  String get pdfParseFailed =>
      'Could not parse the PDF — export CSV or Excel from your bank instead';

  @override
  String get wipeDataTitle => 'Erase all data';

  @override
  String get wipeDataBody =>
      'All transactions, budgets, goals, rules and recurring payments will be deleted; categories and accounts reset to defaults. This cannot be undone. Continue?';

  @override
  String get wipeDataDone => 'Data erased';

  @override
  String get wipe => 'Erase';

  @override
  String get biometricsButton => 'Unlock with biometrics';

  @override
  String get biometricsReason => 'Unlock Numo';

  @override
  String get biometricsTitle => 'Biometric unlock';

  @override
  String get biometricsSubtitle =>
      'Touch ID, Face ID or fingerprint — alongside your PIN';

  @override
  String get biometricsNeedPin =>
      'Set a PIN first — biometrics work alongside it';

  @override
  String get biometricsEnabledToast => 'Biometrics enabled';

  @override
  String get biometricsDisabledToast => 'Biometrics disabled';

  @override
  String get biometricsErrorTitle => 'Biometrics unavailable';

  @override
  String get biometricsNotEnrolled =>
      'No biometrics enrolled. Add a fingerprint or Face ID in system settings and try again.';

  @override
  String get biometricsNotAvailable =>
      'This device has no supported biometrics.';

  @override
  String get biometricsLockedOut =>
      'Biometrics are temporarily locked — sign in with your system password and try again.';

  @override
  String biometricsFailed(String message) {
    return 'Biometric check failed: $message';
  }

  @override
  String whatsNewTitle(String version) {
    return 'What\'s new in $version';
  }

  @override
  String get ok => 'Got it';

  @override
  String get updateCheckFailed =>
      'Could not check for updates — check your network access';

  @override
  String get goalAccountLabel => 'Goal account';

  @override
  String get topUpFromAccount => 'Take from account';

  @override
  String get currencyNoRate =>
      'No exchange rate available — use the account currency or wait for rates to load';

  @override
  String convertedFrom(String amount, String symbol) {
    return '$amount $symbol converted';
  }

  @override
  String get personalizationGroup => 'Personalization';

  @override
  String get accentColorTitle => 'Accent color';

  @override
  String get dataGroup => 'Data & security';

  @override
  String get statementsFolderTitle => 'Statements folder';

  @override
  String get statementsFolderExplainer =>
      'Point Numo at the folder where you save bank statements — new files are detected on launch and offered for import.';

  @override
  String statementFound(String name) {
    return 'New statement found: $name';
  }

  @override
  String get importAction => 'Import';

  @override
  String get uiScaleTitle => 'Interface scale';

  @override
  String get scaleCompact => 'Compact';

  @override
  String get scaleDefault => 'Default';

  @override
  String get scaleLarge => 'Large';

  @override
  String get scaleXLarge => 'Extra large';

  @override
  String get updateNow => 'Update now';

  @override
  String get updating => 'Downloading update…';

  @override
  String get updateRestartNote => 'The app will close and restart itself';

  @override
  String get updateFailed =>
      'Automatic update failed — open the release page instead';

  @override
  String get openPage => 'Open page';

  @override
  String get csvHeaderDate => 'Date';

  @override
  String get csvHeaderType => 'Type';

  @override
  String get csvHeaderAmount => 'Amount';

  @override
  String get csvHeaderCurrency => 'Currency';

  @override
  String get csvHeaderCategory => 'Category';

  @override
  String get csvHeaderAccount => 'Account';

  @override
  String get csvHeaderNote => 'Note';
}
