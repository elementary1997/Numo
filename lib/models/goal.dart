import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData;

import 'category.dart' show CategoryIcons;

/// Цель накопления: целевая сумма, накоплено, опциональный срок.
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
    this.accountId,
  });

  final String id;
  final String title;
  final String iconKey;
  final Color color;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  /// Счёт, на котором копятся деньги цели (опционально).
  final String? accountId;

  IconData get icon => CategoryIcons.resolve(iconKey);
  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);
  bool get reached => savedAmount >= targetAmount && targetAmount > 0;
  double get remaining => (targetAmount - savedAmount).clamp(0, double.infinity);

  /// Сколько откладывать в месяц, чтобы успеть к сроку; null — без
  /// срока, срок прошёл или цель достигнута.
  double? monthlyNeeded({DateTime? now}) {
    final d = deadline;
    if (d == null || reached) return null;
    final today = now ?? DateTime.now();
    final days = d.difference(today).inDays;
    if (days <= 0) return null;
    return remaining / (days / 30.44);
  }

  Goal copyWith({
    String? title,
    String? iconKey,
    Color? color,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? accountId,
    bool clearDeadline = false,
  }) =>
      Goal(
        id: id,
        title: title ?? this.title,
        iconKey: iconKey ?? this.iconKey,
        color: color ?? this.color,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        deadline: clearDeadline ? null : (deadline ?? this.deadline),
        accountId: accountId ?? this.accountId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'color': color.toARGB32(),
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': deadline?.toIso8601String(),
        'accountId': accountId,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        iconKey: json['iconKey'] as String,
        color: Color(json['color'] as int),
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: ((json['savedAmount'] as num?) ?? 0).toDouble(),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
        accountId: json['accountId'] as String?,
      );
}
