import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData;

import '../core/theme.dart';
import 'category.dart' show CategoryIcons;

/// Поддерживаемые валюты счетов.
abstract final class Currencies {
  static const rub = 'RUB';
  static const supported = ['RUB', 'USD', 'EUR'];

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

/// Тип счёта. У вклада и накопительного есть процентная ставка,
/// у вклада — ещё и срок.
enum AccountKind { card, cash, deposit, savings }

/// Разбор типа с поддержкой legacy-значения 'regular' (до v1.1).
AccountKind accountKindFrom(String? raw) => switch (raw) {
      'cash' => AccountKind.cash,
      'deposit' => AccountKind.deposit,
      'savings' => AccountKind.savings,
      _ => AccountKind.card,
    };

/// Счёт пользователя: наличные, карта, вклад — со своей валютой.
class Account {
  const Account({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    this.currency = Currencies.rub,
    this.archived = false,
    this.kind = AccountKind.card,
    this.rate,
    this.openedAt,
    this.closesAt,
    this.shared = false,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String iconKey;
  final Color color;
  final String currency;
  final bool archived;
  final AccountKind kind;

  /// Ставка вклада, % годовых.
  final double? rate;
  final DateTime? openedAt;
  final DateTime? closesAt;

  /// Общий счёт: он и операции по нему уезжают в общую папку
  /// и сливаются с данными других участников (ADR-0014).
  final bool shared;

  /// Когда счёт последний раз менялся — для слияния общих счетов.
  final DateTime? updatedAt;

  IconData get icon => CategoryIcons.resolve(iconKey);
  bool get isRub => currency == Currencies.rub;
  bool get isDeposit => kind == AccountKind.deposit;

  /// Счёт с процентной ставкой (вклад или накопительный).
  bool get hasRate =>
      kind == AccountKind.deposit || kind == AccountKind.savings;

  /// Прогноз суммы к дате закрытия вклада: простые проценты от
  /// текущего баланса за срок «открытие → закрытие». Оценка «≈»:
  /// пополнения и капитализация не моделируются.
  double? projectedAtClose(double balance) {
    if (!isDeposit || rate == null || openedAt == null || closesAt == null) {
      return null;
    }
    final days = closesAt!.difference(openedAt!).inDays;
    if (days <= 0) return null;
    return balance * (1 + rate! / 100 * days / 365);
  }

  Account copyWith({
    String? title,
    String? iconKey,
    Color? color,
    String? currency,
    bool? archived,
    AccountKind? kind,
    double? rate,
    DateTime? openedAt,
    DateTime? closesAt,
    bool? shared,
    DateTime? updatedAt,
  }) =>
      Account(
        id: id,
        title: title ?? this.title,
        iconKey: iconKey ?? this.iconKey,
        color: color ?? this.color,
        currency: currency ?? this.currency,
        archived: archived ?? this.archived,
        kind: kind ?? this.kind,
        rate: rate ?? this.rate,
        openedAt: openedAt ?? this.openedAt,
        closesAt: closesAt ?? this.closesAt,
        shared: shared ?? this.shared,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'color': color.toARGB32(),
        'currency': currency,
        'archived': archived,
        'kind': kind.name,
        'rate': rate,
        'openedAt': openedAt?.toIso8601String(),
        'closesAt': closesAt?.toIso8601String(),
        'shared': shared,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        title: json['title'] as String,
        iconKey: json['iconKey'] as String,
        color: Color(json['color'] as int),
        currency: (json['currency'] as String?) ?? Currencies.rub,
        archived: (json['archived'] as bool?) ?? false,
        kind: accountKindFrom(json['kind'] as String?),
        rate: (json['rate'] as num?)?.toDouble(),
        openedAt: json['openedAt'] == null
            ? null
            : DateTime.parse(json['openedAt'] as String),
        closesAt: json['closesAt'] == null
            ? null
            : DateTime.parse(json['closesAt'] as String),
        shared: (json['shared'] as bool?) ?? false,
        updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? ''),
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

  static const mainEn = Account(
    id: 'main',
    title: 'Main',
    iconKey: 'savings',
    color: NumoColors.violet,
  );

  static Account mainFor(String languageCode) =>
      languageCode == 'ru' ? main : mainEn;
}

/// Поиск счёта с фолбэком на основной.
extension AccountLookup on List<Account> {
  Account byId(String id) =>
      firstWhere((a) => a.id == id, orElse: () => Accounts.main);
}
