import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Категория операции. Пока набор фиксированный; пользовательские
/// категории — следующий шаг.
class TxCategory {
  const TxCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.isIncome = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final bool isIncome;
}

abstract final class Categories {
  static const groceries = TxCategory(
    id: 'groceries',
    title: 'Продукты',
    icon: Icons.shopping_basket_rounded,
    color: NumoColors.mint,
  );
  static const cafe = TxCategory(
    id: 'cafe',
    title: 'Кафе и рестораны',
    icon: Icons.restaurant_rounded,
    color: NumoColors.coral,
  );
  static const transport = TxCategory(
    id: 'transport',
    title: 'Транспорт',
    icon: Icons.directions_bus_rounded,
    color: NumoColors.sky,
  );
  static const home = TxCategory(
    id: 'home',
    title: 'Дом и ЖКХ',
    icon: Icons.home_rounded,
    color: NumoColors.amber,
  );
  static const health = TxCategory(
    id: 'health',
    title: 'Здоровье',
    icon: Icons.favorite_rounded,
    color: NumoColors.pink,
  );
  static const entertainment = TxCategory(
    id: 'entertainment',
    title: 'Развлечения',
    icon: Icons.movie_rounded,
    color: NumoColors.violet,
  );
  static const shopping = TxCategory(
    id: 'shopping',
    title: 'Покупки',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFF9D6BFF),
  );
  static const other = TxCategory(
    id: 'other',
    title: 'Прочее',
    icon: Icons.category_rounded,
    color: Color(0xFF8E8AA6),
  );
  static const salary = TxCategory(
    id: 'salary',
    title: 'Зарплата',
    icon: Icons.work_rounded,
    color: NumoColors.mint,
    isIncome: true,
  );
  static const freelance = TxCategory(
    id: 'freelance',
    title: 'Подработка',
    icon: Icons.laptop_mac_rounded,
    color: NumoColors.sky,
    isIncome: true,
  );
  static const gifts = TxCategory(
    id: 'gifts',
    title: 'Подарки',
    icon: Icons.card_giftcard_rounded,
    color: NumoColors.pink,
    isIncome: true,
  );

  static const expense = [
    groceries,
    cafe,
    transport,
    home,
    health,
    entertainment,
    shopping,
    other,
  ];

  static const income = [salary, freelance, gifts];

  static const all = [...expense, ...income];

  static TxCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => other);
}
