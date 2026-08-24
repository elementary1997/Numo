enum TxType { expense, income }

/// Финансовая операция. Сумма всегда положительная,
/// знак определяется типом.
class Tx {
  const Tx({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
  });

  final String id;
  final TxType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;

  bool get isExpense => type == TxType.expense;

  /// Вклад операции в баланс: расходы со знаком минус.
  double get signedAmount => isExpense ? -amount : amount;

  Tx copyWith({
    TxType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) =>
      Tx(
        id: id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
        id: json['id'] as String,
        type: TxType.values.byName(json['type'] as String),
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        date: DateTime.parse(json['date'] as String),
        note: (json['note'] as String?) ?? '',
      );
}
