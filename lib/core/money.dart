import 'package:intl/intl.dart';

final _ruble = NumberFormat.currency(
  locale: 'ru_RU',
  symbol: '₽',
  decimalDigits: 0,
);

final _rubleExact = NumberFormat.currency(
  locale: 'ru_RU',
  symbol: '₽',
  decimalDigits: 2,
);

/// «12 340 ₽» — суммы без копеек, для карточек и графиков.
String formatMoney(double value) => _ruble.format(value);

/// «12 340,50 ₽» — точная сумма, если есть копейки.
String formatMoneyExact(double value) =>
    value == value.roundToDouble() ? _ruble.format(value) : _rubleExact.format(value);

/// «+12 340 ₽» / «−12 340 ₽» со знаком операции.
String formatSigned(double value, {required bool isExpense}) =>
    '${isExpense ? '−' : '+'}${formatMoneyExact(value.abs())}';

/// Сумма в произвольной валюте: «1 250 $», «12 340 ₽».
String formatMoneyIn(double value, String symbol) {
  final formatted = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: symbol,
    decimalDigits: value == value.roundToDouble() ? 0 : 2,
  ).format(value);
  return formatted;
}
