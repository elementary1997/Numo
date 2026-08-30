import 'dart:convert';

import '../models/account.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/recurring.dart';
import '../models/transaction.dart';

/// Полное содержимое бэкапа.
class BackupData {
  const BackupData({
    required this.transactions,
    required this.categories,
    this.accounts = const [],
    this.budgets = const {},
    this.recurring = const [],
    this.goals = const [],
  });

  final List<Tx> transactions;
  final List<TxCategory> categories;
  final List<Account> accounts;
  final Map<String, double> budgets;
  final List<RecurringRule> recurring;
  final List<Goal> goals;
}

/// Почему файл бэкапа не удалось прочитать. Текст для пользователя
/// выбирает UI — сообщение должно быть на языке интерфейса.
enum BackupError { notJson, notNumo, tooNew, corrupted }

/// Ошибка разбора бэкапа с машинным кодом причины.
class BackupException extends FormatException {
  BackupException(this.error, {this.version}) : super(error.name);

  final BackupError error;

  /// Версия формата из файла — заполнена для [BackupError.tooNew].
  final int? version;
}

/// Формат бэкапа Numo: версионированный JSON со всеми данными.
/// v1 — операции и категории; v2 добавила счета, бюджеты и
/// регулярные правила; v3 — цели. Старые файлы читаются с пустыми
/// новыми полями.
abstract final class Backup {
  static const version = 3;

  static String encode(BackupData data) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'numo',
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': data.categories.map((c) => c.toJson()).toList(),
      'transactions': data.transactions.map((t) => t.toJson()).toList(),
      'accounts': data.accounts.map((a) => a.toJson()).toList(),
      'budgets': data.budgets,
      'recurring': data.recurring.map((r) => r.toJson()).toList(),
      'goals': data.goals.map((g) => g.toJson()).toList(),
    });
  }

  /// Разбирает бэкап; бросает [BackupException] с кодом причины,
  /// если файл не похож на бэкап Numo.
  static BackupData decode(String raw) {
    final Object? data;
    try {
      data = jsonDecode(raw);
    } catch (_) {
      throw BackupException(BackupError.notJson);
    }
    if (data is! Map<String, dynamic> || data['app'] != 'numo') {
      throw BackupException(BackupError.notNumo);
    }
    final fileVersion = data['version'] as int? ?? 0;
    if (fileVersion > version) {
      throw BackupException(BackupError.tooNew, version: fileVersion);
    }
    try {
      return BackupData(
        categories: (data['categories'] as List)
            .map((e) => TxCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        transactions: ((data['transactions'] as List)
            .map((e) => Tx.fromJson(e as Map<String, dynamic>))
            .toList())
          ..sort((a, b) => b.date.compareTo(a.date)),
        accounts: ((data['accounts'] as List?) ?? const [])
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList(),
        budgets: ((data['budgets'] as Map<String, dynamic>?) ?? const {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        recurring: ((data['recurring'] as List?) ?? const [])
            .map((e) => RecurringRule.fromJson(e as Map<String, dynamic>))
            .toList(),
        goals: ((data['goals'] as List?) ?? const [])
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      throw BackupException(BackupError.corrupted);
    }
  }
}
