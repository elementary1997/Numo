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
    this.accountId = 'main',
    this.note = '',
  });

  final String id;
  final TxType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String accountId;
  final String note;

  bool get isExpense => type == TxType.expense;

  /// Половинка перевода между счетами: участвует в балансах счетов,
  /// но исключается из статистики доходов/расходов.
  bool get isTransfer => categoryId == 'transfer';

  /// Корректировка баланса (начальный баланс и сверки) —
  /// тоже вне статистики доходов/расходов.
  bool get isAdjustment => categoryId == 'adjustment';

  /// Не участвует в статистике доходов/расходов.
  bool get isSystem => isTransfer || isAdjustment;

  /// Вклад операции в баланс: расходы со знаком минус.
  double get signedAmount => isExpense ? -amount : amount;

  Tx copyWith({
    TxType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? accountId,
    String? note,
  }) =>
      Tx(
        id: id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        accountId: accountId ?? this.accountId,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'accountId': accountId,
        'note': note,
      };

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
        id: json['id'] as String,
        type: TxType.values.byName(json['type'] as String),
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        date: DateTime.parse(json['date'] as String),
        accountId: (json['accountId'] as String?) ?? 'main',
        note: (json['note'] as String?) ?? '',
      );
}
