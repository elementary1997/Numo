import 'transaction.dart';

/// Правило регулярной операции: раз в месяц в заданный день.
class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.dayOfMonth,
    required this.startDate,
    this.appliedThrough,
    this.note = '',
  });

  final String id;
  final TxType type;
  final double amount;
  final String categoryId;
  final String note;

  /// 1–31; в коротких месяцах прижимается к последнему дню.
  final int dayOfMonth;

  /// Первый месяц действия правила.
  final DateTime startDate;

  /// По какую дату включительно правило уже материализовано.
  /// Операции создаются только позже этой даты — удалённая
  /// пользователем операция не возрождается.
  final DateTime? appliedThrough;

  /// Дата срабатывания в конкретном месяце (день прижат к длине месяца).
  DateTime occurrenceIn(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, dayOfMonth.clamp(1, lastDay));
  }

  /// Детерминированный id операции месяца — гарантия идемпотентности.
  String txIdFor(int year, int month) =>
      'rec-$id-$year-${month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'note': note,
        'dayOfMonth': dayOfMonth,
        'startDate': startDate.toIso8601String(),
        'appliedThrough': appliedThrough?.toIso8601String(),
      };

  factory RecurringRule.fromJson(Map<String, dynamic> json) => RecurringRule(
        id: json['id'] as String,
        type: TxType.values.byName(json['type'] as String),
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        note: (json['note'] as String?) ?? '',
        dayOfMonth: json['dayOfMonth'] as int,
        startDate: DateTime.parse(json['startDate'] as String),
        appliedThrough: json['appliedThrough'] == null
            ? null
            : DateTime.parse(json['appliedThrough'] as String),
      );

  RecurringRule copyWith({
    TxType? type,
    double? amount,
    String? categoryId,
    String? note,
    int? dayOfMonth,
    DateTime? appliedThrough,
  }) =>
      RecurringRule(
        id: id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        note: note ?? this.note,
        dayOfMonth: dayOfMonth ?? this.dayOfMonth,
        startDate: startDate,
        appliedThrough: appliedThrough ?? this.appliedThrough,
      );
}
