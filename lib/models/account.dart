import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData;

import '../core/theme.dart';
import 'category.dart' show CategoryIcons;

/// Поддерживаемые валюты счетов.
abstract final class Currencies {
  static const rub = 'RUB';
  static const supported = ['RUB', 'USD', 'EUR', 'CNY', 'KZT', 'AMD', 'RSD'];

  static String symbol(String code) => switch (code) {
        'RUB' => '₽',
        'USD' => r'$',
        'EUR' => '€',
        'CNY' => '¥',
        'KZT' => '₸',
        'AMD' => '֏',
        'RSD' => 'дин',
        _ => code,
      };
}

/// Счёт пользователя: наличные, карта, вклад — со своей валютой.
class Account {
  const Account({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    this.currency = Currencies.rub,
    this.archived = false,
  });

  final String id;
  final String title;
  final String iconKey;
  final Color color;
  final String currency;
  final bool archived;

  IconData get icon => CategoryIcons.resolve(iconKey);
  bool get isRub => currency == Currencies.rub;

  Account copyWith({
    String? title,
    String? iconKey,
    Color? color,
    String? currency,
    bool? archived,
  }) =>
      Account(
        id: id,
        title: title ?? this.title,
        iconKey: iconKey ?? this.iconKey,
        color: color ?? this.color,
        currency: currency ?? this.currency,
        archived: archived ?? this.archived,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'color': color.toARGB32(),
        'currency': currency,
        'archived': archived,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        title: json['title'] as String,
        iconKey: json['iconKey'] as String,
        color: Color(json['color'] as int),
        currency: (json['currency'] as String?) ?? Currencies.rub,
        archived: (json['archived'] as bool?) ?? false,
      );
}

/// Счёт по умолчанию — на него попадают операции, созданные до
/// появления счетов, и он сидируется на чистой установке.
abstract final class Accounts {
  static const main = Account(
    id: 'main',
    title: 'Основной',
    iconKey: 'savings',
    color: NumoColors.violet,
  );
}

/// Поиск счёта с фолбэком на основной.
extension AccountLookup on List<Account> {
  Account byId(String id) =>
      firstWhere((a) => a.id == id, orElse: () => Accounts.main);
}
