import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';

/// Разбор финансов через Anthropic API с ключом пользователя
/// (ADR-0011). Отправляется только агрегированная сводка — суммы по
/// категориям и месяцам, балансы и бюджеты; заметки операций не
/// покидают устройство. Запрос выполняется исключительно по явному
/// действию пользователя.
class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  static const _keyPref = 'numo.ai.key';
  static const _modelPref = 'numo.ai.model';
  static const defaultModel = 'claude-sonnet-5';

  static final _endpoint = Uri.parse('https://api.anthropic.com/v1/messages');

  final http.Client _client;

  Future<String?> get apiKey async =>
      (await SharedPreferences.getInstance()).getString(_keyPref);

  Future<String> get model async =>
      (await SharedPreferences.getInstance()).getString(_modelPref) ??
      defaultModel;

  Future<void> configure({required String key, String? model}) async {
    final prefs = await SharedPreferences.getInstance();
    if (key.isEmpty) {
      await prefs.remove(_keyPref);
    } else {
      await prefs.setString(_keyPref, key);
    }
    if (model == null || model.isEmpty) {
      await prefs.remove(_modelPref);
    } else {
      await prefs.setString(_modelPref, model);
    }
  }

  /// Агрегированная сводка для модели: последние [months] месяцев.
  static Map<String, dynamic> buildSummary({
    required List<Tx> transactions,
    required List<TxCategory> categories,
    required List<Account> accounts,
    required Map<String, double> budgets,
    required DateTime now,
    int months = 3,
  }) {
    String titleOf(String id) => categories.byId(id).title;
    final monthly = <Map<String, dynamic>>[];
    for (var i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i);
      var income = 0.0;
      var expense = 0.0;
      final byCategory = <String, double>{};
      for (final t in transactions) {
        if (t.isSystem) continue;
        if (t.date.year != month.year || t.date.month != month.month) {
          continue;
        }
        if (t.isExpense) {
          expense += t.amount;
          byCategory.update(titleOf(t.categoryId), (v) => v + t.amount,
              ifAbsent: () => t.amount);
        } else {
          income += t.amount;
        }
      }
      monthly.add({
        'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
        'income': income.round(),
        'expense': expense.round(),
        'expenseByCategory':
            byCategory.map((k, v) => MapEntry(k, v.round())),
      });
    }

    final balances = <String, dynamic>{};
    for (final a in accounts.where((a) => !a.archived)) {
      final balance = transactions
          .where((t) => t.accountId == a.id)
          .fold(0.0, (sum, t) => sum + t.signedAmount);
      balances[a.title] = {
        'balance': balance.round(),
        'currency': a.currency,
        if (a.isDeposit && a.rate != null) 'depositRatePercent': a.rate,
      };
    }

    return {
      'currency': 'RUB',
      'months': monthly,
      'accounts': balances,
      'monthlyBudgets':
          budgets.map((k, v) => MapEntry(titleOf(k), v.round())),
    };
  }

  /// Запрашивает у Claude разбор финансов. Бросает [AiException]
  /// с человекочитаемым сообщением.
  Future<String> review({
    required Map<String, dynamic> summary,
    required String languageCode,
  }) async {
    final key = await apiKey;
    if (key == null || key.isEmpty) {
      throw const AiException('API key is not set');
    }
    final lang = languageCode == 'ru' ? 'русском' : 'English';
    final prompt = languageCode == 'ru'
        ? 'Ты — финансовый аналитик приложения Numo. Ниже сводка личных '
            'финансов пользователя в JSON (суммы в рублях). Сделай краткий '
            'разбор на $lang языке: 1) главное о динамике доходов/расходов, '
            '2) паттерны и риски, 3) три конкретных совета. Пиши сжато, '
            'обычным текстом с короткими абзацами, без markdown-разметки.\n\n'
        : 'You are the financial analyst of the Numo app. Below is a JSON '
            'summary of the user\'s personal finances (amounts in RUB). '
            'Give a concise review in $lang: 1) key income/spending '
            'dynamics, 2) patterns and risks, 3) three concrete tips. '
            'Plain text, short paragraphs, no markdown.\n\n';

    final response = await _client
        .post(
          _endpoint,
          headers: {
            'content-type': 'application/json',
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': await model,
            'max_tokens': 1200,
            'messages': [
              {
                'role': 'user',
                'content': prompt + jsonEncode(summary),
              }
            ],
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      final body = utf8.decode(response.bodyBytes);
      String message = 'HTTP ${response.statusCode}';
      try {
        final error =
            (jsonDecode(body) as Map<String, dynamic>)['error'];
        if (error is Map && error['message'] is String) {
          message = error['message'] as String;
        }
      } catch (_) {}
      throw AiException(message);
    }
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = json['content'] as List?;
    final text = content
        ?.whereType<Map<String, dynamic>>()
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join('\n');
    if (text == null || text.isEmpty) {
      throw const AiException('Empty response');
    }
    return text;
  }
}

class AiException implements Exception {
  const AiException(this.message);

  final String message;

  @override
  String toString() => message;
}
