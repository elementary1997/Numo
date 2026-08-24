import 'dart:convert';

import '../models/category.dart';
import '../models/transaction.dart';

/// Формат бэкапа Numo: версионированный JSON со всеми данными.
/// Версия позволяет читать старые бэкапы после смены схемы.
abstract final class Backup {
  static const version = 1;

  static String encode({
    required List<Tx> transactions,
    required List<TxCategory> categories,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'numo',
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    });
  }

  /// Разбирает бэкап; бросает [FormatException] с человекочитаемым
  /// сообщением, если файл не похож на бэкап Numo.
  static ({List<Tx> transactions, List<TxCategory> categories}) decode(
      String raw) {
    final Object? data;
    try {
      data = jsonDecode(raw);
    } catch (_) {
      throw const FormatException('Файл не является корректным JSON');
    }
    if (data is! Map<String, dynamic> || data['app'] != 'numo') {
      throw const FormatException('Это не файл бэкапа Numo');
    }
    final fileVersion = data['version'] as int? ?? 0;
    if (fileVersion > version) {
      throw FormatException(
          'Бэкап создан более новой версией приложения (v$fileVersion)');
    }
    try {
      final categories = (data['categories'] as List)
          .map((e) => TxCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      final transactions = (data['transactions'] as List)
          .map((e) => Tx.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return (transactions: transactions, categories: categories);
    } catch (_) {
      throw const FormatException('Файл бэкапа повреждён');
    }
  }
}
