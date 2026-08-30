import '../models/transaction.dart';

/// Кто кому сколько должен по итогам общих трат.
class Debt {
  const Debt({
    required this.from,
    required this.to,
    required this.amount,
  });

  /// Кто должен.
  final String from;

  /// Кому.
  final String to;

  /// Сколько, в валюте расчёта (рубли).
  final double amount;
}

/// Считает взаимные долги по операциям с раскладкой (ADR-0014).
///
/// Платит всегда автор операции, доли из [Tx.split] говорят, за кого
/// он заплатил. Итог сворачивается: если Аня должна Паше 1000, а Паша
/// Ане 300, останется один долг на 700.
///
/// [amountOf] приводит сумму операции к валюте расчёта — курсы ЦБ
/// живут в провайдерах, чистая логика о них не знает.
List<Debt> settleDebts({
  required List<Tx> transactions,
  double Function(Tx tx)? amountOf,
}) {
  final amount = amountOf ?? (Tx t) => t.amount;

  // Баланс участника: положительный — ему должны, отрицательный — он.
  final balances = <String, double>{};
  for (final tx in transactions) {
    final payer = tx.authorId;
    if (payer == null || !tx.isSplit || tx.isDeleted) continue;

    final shares = tx.split!;
    final totalWeight = shares.values.fold(0.0, (a, b) => a + b);
    if (totalWeight <= 0) continue;

    final total = amount(tx);
    shares.forEach((member, weight) {
      final owed = total * weight / totalWeight;
      if (member == payer) return; // свою долю платящий себе не должен
      balances.update(member, (v) => v - owed, ifAbsent: () => -owed);
      balances.update(payer, (v) => v + owed, ifAbsent: () => owed);
    });
  }

  // Сводим к минимальному числу переводов: самый крупный должник
  // отдаёт самому крупному кредитору, и так далее.
  final debtors = <MapEntry<String, double>>[];
  final creditors = <MapEntry<String, double>>[];
  balances.forEach((member, balance) {
    if (balance < -0.01) debtors.add(MapEntry(member, -balance));
    if (balance > 0.01) creditors.add(MapEntry(member, balance));
  });
  debtors.sort((a, b) => b.value.compareTo(a.value));
  creditors.sort((a, b) => b.value.compareTo(a.value));

  final debts = <Debt>[];
  var i = 0;
  var j = 0;
  var owed = debtors.isEmpty ? 0.0 : debtors.first.value;
  var due = creditors.isEmpty ? 0.0 : creditors.first.value;
  while (i < debtors.length && j < creditors.length) {
    final payment = owed < due ? owed : due;
    if (payment > 0.01) {
      debts.add(Debt(
        from: debtors[i].key,
        to: creditors[j].key,
        amount: payment,
      ));
    }
    owed -= payment;
    due -= payment;
    if (owed <= 0.01) {
      i++;
      if (i < debtors.length) owed = debtors[i].value;
    }
    if (due <= 0.01) {
      j++;
      if (j < creditors.length) due = creditors[j].value;
    }
  }
  return debts;
}

/// Раскладка поровну между участниками.
Map<String, double> splitEqually(Iterable<String> memberIds) =>
    {for (final id in memberIds) id: 1};
