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
