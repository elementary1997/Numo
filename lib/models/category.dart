import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Каталог иконок категорий. Иконки хранятся по строковому ключу,
/// а не по codePoint — динамический IconData ломает tree-shake иконок
/// в release-сборке.
abstract final class CategoryIcons {
  static const Map<String, IconData> byKey = {
    'basket': Icons.shopping_basket_rounded,
    'restaurant': Icons.restaurant_rounded,
    'bus': Icons.directions_bus_rounded,
    'home': Icons.home_rounded,
    'heart': Icons.favorite_rounded,
    'movie': Icons.movie_rounded,
    'bag': Icons.shopping_bag_rounded,
    'category': Icons.category_rounded,
    'work': Icons.work_rounded,
    'laptop': Icons.laptop_mac_rounded,
    'gift': Icons.card_giftcard_rounded,
    'car': Icons.directions_car_rounded,
    'coffee': Icons.local_cafe_rounded,
    'fitness': Icons.fitness_center_rounded,
    'school': Icons.school_rounded,
    'flight': Icons.flight_rounded,
    'pets': Icons.pets_rounded,
    'phone': Icons.smartphone_rounded,
    'music': Icons.music_note_rounded,
    'book': Icons.menu_book_rounded,
    'child': Icons.child_care_rounded,
    'build': Icons.build_rounded,
    'savings': Icons.savings_rounded,
    'percent': Icons.percent_rounded,
    'swap': Icons.swap_horiz_rounded,
    'cash': Icons.payments_rounded,
    'card': Icons.credit_card_rounded,
  };

  static IconData resolve(String key) =>
      byKey[key] ?? Icons.category_rounded;
}

/// Палитра, из которой выбирается цвет категории.
abstract final class CategoryColors {
  static const palette = [
    NumoColors.mint,
    NumoColors.coral,
    NumoColors.sky,
    NumoColors.amber,
    NumoColors.pink,
    NumoColors.violet,
    Color(0xFF9D6BFF),
    Color(0xFF8E8AA6),
    Color(0xFF5CD6C0),
    Color(0xFFFF8A5C),
    Color(0xFF6BA8FF),
    Color(0xFFC7E05C),
  ];
}

/// Категория операции. Встроенные сидируются при первом запуске,
/// пользовательские создаются в приложении; и те и другие живут
/// в хранилище и редактируются одинаково.
class TxCategory {
  const TxCategory({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    this.isIncome = false,
    this.archived = false,
  });

  final String id;
  final String title;
  final String iconKey;
  final Color color;
  final bool isIncome;

  /// Архивная категория скрыта из выбора, но продолжает
  /// корректно отображаться в истории операций.
  final bool archived;

  IconData get icon => CategoryIcons.resolve(iconKey);

  TxCategory copyWith({
    String? title,
    String? iconKey,
    Color? color,
    bool? archived,
  }) =>
      TxCategory(
        id: id,
        title: title ?? this.title,
        iconKey: iconKey ?? this.iconKey,
        color: color ?? this.color,
        isIncome: isIncome,
        archived: archived ?? this.archived,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'color': color.toARGB32(),
        'isIncome': isIncome,
        'archived': archived,
      };

  factory TxCategory.fromJson(Map<String, dynamic> json) => TxCategory(
        id: json['id'] as String,
        title: json['title'] as String,
        iconKey: json['iconKey'] as String,
        color: Color(json['color'] as int),
        isIncome: (json['isIncome'] as bool?) ?? false,
        archived: (json['archived'] as bool?) ?? false,
      );
}

/// Встроенный набор категорий — сидируется в хранилище при первом
/// запуске. После этого источник правды — categoriesProvider;
/// здесь остаётся только набор по умолчанию и фолбэк [other].
abstract final class Categories {
  static const groceries = TxCategory(
    id: 'groceries',
    title: 'Продукты',
    iconKey: 'basket',
    color: NumoColors.mint,
  );
  static const cafe = TxCategory(
    id: 'cafe',
    title: 'Кафе и рестораны',
    iconKey: 'restaurant',
    color: NumoColors.coral,
  );
  static const transport = TxCategory(
    id: 'transport',
    title: 'Транспорт',
    iconKey: 'bus',
    color: NumoColors.sky,
  );
  static const home = TxCategory(
    id: 'home',
    title: 'Дом и ЖКХ',
    iconKey: 'home',
    color: NumoColors.amber,
  );
  static const health = TxCategory(
    id: 'health',
    title: 'Здоровье',
    iconKey: 'heart',
    color: NumoColors.pink,
  );
  static const entertainment = TxCategory(
    id: 'entertainment',
    title: 'Развлечения',
    iconKey: 'movie',
    color: NumoColors.violet,
  );
  static const shopping = TxCategory(
    id: 'shopping',
    title: 'Покупки',
    iconKey: 'bag',
    color: Color(0xFF9D6BFF),
  );
  static const other = TxCategory(
    id: 'other',
    title: 'Прочее',
    iconKey: 'category',
    color: Color(0xFF8E8AA6),
  );
  static const salary = TxCategory(
    id: 'salary',
    title: 'Зарплата',
    iconKey: 'work',
    color: NumoColors.mint,
    isIncome: true,
  );
  static const freelance = TxCategory(
    id: 'freelance',
    title: 'Подработка',
    iconKey: 'laptop',
    color: NumoColors.sky,
    isIncome: true,
  );
  static const gifts = TxCategory(
    id: 'gifts',
    title: 'Подарки',
    iconKey: 'gift',
    color: NumoColors.pink,
    isIncome: true,
  );

  /// Системная категория переводов между счетами: не показывается
  /// в выборе категорий и исключена из статистики доходов/расходов.
  static const transfer = TxCategory(
    id: 'transfer',
    title: 'Перевод',
    iconKey: 'swap',
    color: Color(0xFF8E8AA6),
  );

  /// Английский встроенный набор — те же id/иконки/цвета.
  static List<TxCategory> get defaultsEn => [
        for (final c in defaults)
          TxCategory(
            id: c.id,
            title: _titlesEn[c.id] ?? c.title,
            iconKey: c.iconKey,
            color: c.color,
            isIncome: c.isIncome,
          ),
      ];

  static const _titlesEn = {
    'groceries': 'Groceries',
    'cafe': 'Cafes & dining',
    'transport': 'Transport',
    'home': 'Home & utilities',
    'health': 'Health',
    'entertainment': 'Entertainment',
    'shopping': 'Shopping',
    'other': 'Other',
    'salary': 'Salary',
    'freelance': 'Side income',
    'gifts': 'Gifts',
    'transfer': 'Transfer',
  };

  /// Набор для сидирования по языку системы.
  static List<TxCategory> defaultsFor(String languageCode) =>
      languageCode == 'ru' ? defaults : defaultsEn;

  /// Название встроенной категории на данном языке; null для
  /// пользовательских категорий.
  static String? defaultTitle(String id, String languageCode) {
    for (final c in defaults) {
      if (c.id == id) {
        return languageCode == 'ru' ? c.title : _titlesEn[id];
      }
    }
    return null;
  }

  /// Название не менялось пользователем (совпадает с ru- или
  /// en-дефолтом) — такие можно переводить при смене языка.
  static bool isUntouchedDefault(String id, String title) =>
      title == defaultTitle(id, 'ru') || title == defaultTitle(id, 'en');

  static const defaults = [
    groceries,
    cafe,
    transport,
    home,
    health,
    entertainment,
    shopping,
    other,
    salary,
    freelance,
    gifts,
    transfer,
  ];
}

/// Поиск категории в списке с фолбэком на «Прочее» —
/// операция никогда не остаётся без категории.
extension CategoryLookup on List<TxCategory> {
  TxCategory byId(String id) =>
      firstWhere((c) => c.id == id, orElse: () => Categories.other);
}
