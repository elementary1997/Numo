/// Встроенный список изменений для диалога «Что нового» после
/// обновления. Источник правды для истории — CHANGELOG.md; здесь
/// дублируются пункты, которые стоит показать пользователю.
class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.itemsRu,
    required this.itemsEn,
  });

  final String version;
  final List<String> itemsRu;
  final List<String> itemsEn;

  List<String> items(String languageCode) =>
      languageCode == 'ru' ? itemsRu : itemsEn;
}

const changelog = <ChangelogEntry>[
  ChangelogEntry(
    version: '1.13.2',
    itemsRu: [
      'Исправлен отказ запуска «duplicate column name»: миграции больше не повторяют уже сделанные шаги',
    ],
    itemsEn: [
      'Fixed the "duplicate column name" startup failure: migrations no longer repeat steps already applied',
    ],
  ),
  ChangelogEntry(
    version: '1.13.1',
    itemsRu: [
      'Приложение больше не запускается «в никуда»: окно открывается сразу, а при сбое подготовки видно, что случилось',
    ],
    itemsEn: [
      'The app no longer starts into nothing: the window opens right away, and a failed startup explains itself',
    ],
  ),
  ChangelogEntry(
    version: '1.13.0',
    itemsRu: [
      'QR-код приглашения: покажите его близкому — снимет телефоном',
      'Мелкие доли на круговой диаграмме больше не пропадают',
    ],
    itemsEn: [
      'Invite QR code: show it and the other person just points a phone at it',
      'Small slices on the donut chart no longer vanish',
    ],
  ),
  ChangelogEntry(
    version: '1.12.2',
    itemsRu: [
      'macOS: неудачное обновление больше не может оставить без приложения',
      'Если обновление не встало, причина показывается прямо в диалоге',
    ],
    itemsEn: [
      'macOS: a failed update can no longer leave you without the app',
      'When an update does not apply, the reason is shown right in the dialog',
    ],
  ),
  ChangelogEntry(
    version: '1.12.1',
    itemsRu: [
      'Windows: подмена файлов при обновлении надёжнее, а причину неудачи видно в логе',
      '«Обновление не установилось» больше не появляется после сорванного скачивания',
    ],
    itemsEn: [
      'Windows: file replacement during update is sturdier, and failures are visible in the log',
      'No more false "update did not install" after a download that never finished',
    ],
  ),
  ChangelogEntry(
    version: '1.12.0',
    itemsRu: [
      'Общие траты делятся по долям: видно, кто кому должен, и долг можно отметить погашенным',
      'Напоминания: накануне регулярного платежа и при перерасходе бюджета',
      'Лента операций читается страницами из базы — быстрее на больших историях',
    ],
    itemsEn: [
      'Shared expenses split by shares: see who owes whom and mark a debt settled',
      'Reminders: the day before a recurring payment and when a budget is exceeded',
      'The transactions feed loads pages from the database — faster on long histories',
    ],
  ),
  ChangelogEntry(
    version: '1.11.0',
    itemsRu: [
      'Новая версия больше не проходит мимо: баннер на «Обзоре», точка у «Настроек» и понятное состояние в настройках',
      'Доступность: суммы, графики и бюджеты читаются скринридером, кнопки-иконки подписаны',
    ],
    itemsEn: [
      'A new release no longer slips past: a banner on the dashboard, a dot on Settings and a clear state in settings',
      'Accessibility: amounts, charts and budgets are read out by screen readers, icon buttons are labelled',
    ],
  ),
  ChangelogEntry(
    version: '1.10.0',
    itemsRu: [
      'Код приглашения: покажите его близкому, он вставит код у себя — и участники сразу видят друг друга по именам',
    ],
    itemsEn: [
      'Invite code: show it to the other person, they paste it on their side — members recognise each other right away',
    ],
  ),
  ChangelogEntry(
    version: '1.9.0',
    itemsRu: [
      'Общие счета: ведите счёт вместе с другим человеком через общую папку в облаке — операции сливаются, а не затирают друг друга',
      'В ленте видно, кто из участников внёс операцию',
      'Валютные счета больше не искажают статистику: суммы сводятся в рубли по курсу ЦБ',
      'Импорт выписки перестал терять одинаковые операции за один день',
      'Windows: автообновление больше не срывается на кириллице в пути к папке пользователя',
    ],
    itemsEn: [
      'Shared accounts: keep an account together with another person through a shared cloud folder — changes merge instead of overwriting each other',
      'The feed shows which member added a transaction',
      'Foreign-currency accounts no longer skew the stats: amounts are converted to rubles at the CBR rate',
      'Statement import no longer drops identical transactions made on the same day',
      'Windows: auto-update no longer breaks on non-Latin characters in the user folder path',
    ],
  ),
  ChangelogEntry(
    version: '1.8.0',
    itemsRu: [
      'Новые категории: «Переводы», «Вклады» и «Пополнения» — переводы и пополнения из выписок больше не падают в «Прочее»',
      'Журнал импортов: список уже загруженных файлов прямо на экране импорта',
      'Исправлен чёрный экран после импорта из бокового меню',
    ],
    itemsEn: [
      'New categories: Transfers, Deposits and Top-ups — statement transfers no longer land in Other',
      'Import journal: previously imported files listed right on the import screen',
      'Fixed the black screen after importing from the sidebar section',
    ],
  ),
  ChangelogEntry(
    version: '1.7.0',
    itemsRu: [
      'Импорт выписок распределяет операции по категориям банка — «Прочее» больше не растёт',
      'Кнопка «Применить к существующим» в правилах раскладывает уже импортированное по категориям',
      'Уведомление о новой версии приходит надёжно: проверка раз в час и при возврате к окну',
      'macOS: окно сразу открывается с боковой панелью и запоминает размер',
      'API-ключ AI-разбора переехал в системное хранилище секретов',
    ],
    itemsEn: [
      'Statement import assigns categories from bank rubrics — no more everything in Other',
      '“Apply to existing” in rules reclassifies already imported operations',
      'New-version notifications are reliable: re-check hourly and on window focus',
      'macOS: the window opens with the sidebar right away and remembers its size',
      'The AI review API key moved into the system secret storage',
    ],
  ),
  ChangelogEntry(
    version: '1.6.1',
    itemsRu: [
      'Масштаб интерфейса исправлен: контент больше не обрезается, боковая панель на месте при любом масштабе',
    ],
    itemsEn: [
      'Interface scale fixed: content is no longer cropped, the sidebar stays at any scale',
    ],
  ),
  ChangelogEntry(
    version: '1.6.0',
    itemsRu: [
      'Импорт настоящих PDF-выписок СберБанка: категории банка и продавец переносятся в описание, приходы распознаются',
      'Регулярные платежи: день месяца выбирается календарной сеткой',
    ],
    itemsEn: [
      'Real Sberbank PDF statements import: bank categories and merchant go into the description, incomes are detected',
      'Recurring payments: pick the day of month on a calendar grid',
    ],
  ),
  ChangelogEntry(
    version: '1.5.2',
    itemsRu: [
      'macOS: автообновление надёжно ставится в «Программы» и снимает карантин Gatekeeper',
      'При неудачном обновлении показывается настоящая причина',
    ],
    itemsEn: [
      'macOS: auto-update reliably installs into /Applications and clears Gatekeeper quarantine',
      'Failed updates now show the actual reason',
    ],
  ),
  ChangelogEntry(
    version: '1.5.1',
    itemsRu: [
      'Боковая панель больше не пропадает при увеличенном масштабе интерфейса',
      'Настройка «Вход по биометрии» рядом с PIN — с проверкой и понятной диагностикой',
    ],
    itemsEn: [
      'Sidebar no longer disappears with a larger interface scale',
      'Dedicated “Biometric unlock” setting next to the PIN, with a test check and clear diagnostics',
    ],
  ),
  ChangelogEntry(
    version: '1.5.0',
    itemsRu: [
      'Автообновление: новая версия скачивается и устанавливается сама, приложение перезапускается',
      'Персонализация: масштаб интерфейса — от компактного до очень крупного',
    ],
    itemsEn: [
      'Auto-update: new versions download and install themselves, the app restarts on its own',
      'Personalization: interface scale from compact to extra large',
    ],
  ),
  ChangelogEntry(
    version: '1.4.0',
    itemsRu: [
      'Официальные иконки банков: Сбер, Т-Банк, Альфа, ВТБ, Озон, Яндекс, МТС и другие',
      'Персонализация: выбор акцентного цвета приложения',
      'Папка выписок — новые файлы находятся сами и предлагаются к импорту',
    ],
    itemsEn: [
      'Official bank icons: Sber, T-Bank, Alfa, VTB, Ozon, Yandex, MTS and more',
      'Personalization: pick the app accent color',
      'Statements folder — new files are detected and offered for import',
    ],
  ),
  ChangelogEntry(
    version: '1.3.0',
    itemsRu: [
      'Выбор валюты при вводе операции — конвертация в валюту счёта по курсу ЦБ',
      'Узнаваемые значки банков: Сбер, Т-Банк, МТС, Озон, Совкомбанк, Яндекс',
      'Цель с привязанным счётом обновляется сама от его баланса',
      '«Бюджеты» стали «Лимитами»',
    ],
    itemsEn: [
      'Pick a currency while entering a transaction — converted to the account currency at CBR rates',
      'Recognizable bank logos: Sber, T-Bank, MTS, Ozon, Sovcombank, Yandex',
      'Goals linked to an account now track its balance automatically',
      'Budgets renamed to Limits',
    ],
  ),
  ChangelogEntry(
    version: '1.2.0',
    itemsRu: [
      'Вход по биометрии: Touch ID, Windows Hello, отпечаток или Face ID — как альтернатива PIN',
      'Брендовые иконки счетов: Сбер, Т-Банк, Альфа, ВТБ, Озон, Яндекс и другие',
      'Цель можно привязать к счёту — пополнение делает реальный перевод со счёта-источника',
      'Сумма операции показывается в валюте выбранного счёта',
      'Исправлен доступ к сети на macOS: заработали курсы, проверка обновлений и AI-разбор',
      'Экран блокировки показывает столько точек, сколько цифр в вашем PIN',
      'Графики перерисованы: подписи без наложений, градиентные бары',
      'Категории и счета в горизонтальных списках листаются мышью',
      'Релизные сборки начинаются без демо-данных; в настройках появился полный сброс',
      'Диалог «Что нового» после каждого обновления',
    ],
    itemsEn: [
      'Biometric unlock: Touch ID, Windows Hello, fingerprint or Face ID as a PIN alternative',
      'Brand account icons: Sber, T-Bank, Alfa, VTB, Ozon, Yandex and more',
      'Goals can link to an account — top-ups make a real transfer from a source account',
      'Transaction amounts use the selected account currency',
      'Fixed macOS network access: rates, update checks and AI review now work',
      'The lock screen shows exactly as many dots as your PIN has digits',
      'Charts redrawn: labels no longer overlap, gradient bars',
      'Horizontal lists (categories, accounts) scroll with the mouse',
      'Release builds start clean without demo data; full data reset added to Settings',
      'A “What’s new” dialog after every update',
    ],
  ),
  ChangelogEntry(
    version: '1.1.0',
    itemsRu: [
      'Типы счетов: карта, наличные, вклад, накопительный',
      'Провайдеры AI-разбора: Claude, Cloud.ru и локальные модели через LM Studio',
      'Импорт PDF-выписок Сбербанка',
    ],
    itemsEn: [
      'Account types: card, cash, deposit, savings',
      'AI review providers: Claude, Cloud.ru and local models via LM Studio',
      'Sberbank PDF statement import',
    ],
  ),
];
