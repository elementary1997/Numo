import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'secret_store.dart';

/// Провайдер LLM-разбора. Anthropic говорит на Messages API,
/// остальные — OpenAI-совместимый chat/completions (Cloud.ru,
/// локальный LM Studio, любой свой сервер).
enum AiProvider { anthropic, cloudru, lmstudio, custom }

/// Конфигурация провайдера по умолчанию.
({String endpoint, String model, bool keyRequired}) aiProviderDefaults(
        AiProvider provider) =>
    switch (provider) {
      AiProvider.anthropic => (
          endpoint: 'https://api.anthropic.com/v1/messages',
          model: 'claude-sonnet-5',
          keyRequired: true,
        ),
      AiProvider.cloudru => (
          endpoint:
              'https://foundation-models.api.cloud.ru/v1/chat/completions',
          model: 'openai/gpt-oss-120b',
          keyRequired: true,
        ),
      AiProvider.lmstudio => (
          endpoint: 'http://127.0.0.1:1234/v1/chat/completions',
          model: 'local-model',
          keyRequired: false,
        ),
      AiProvider.custom => (
          endpoint: '',
          model: '',
          keyRequired: false,
        ),
    };

/// Разбор финансов через LLM с ключом пользователя (ADR-0011).
/// Отправляется только агрегированная сводка — суммы по категориям и
/// месяцам, балансы и бюджеты; заметки операций не покидают
/// устройство. Запрос выполняется исключительно по явному действию.
class AiService {
  AiService({http.Client? client, SecretStore? secrets})
      : _client = client ?? http.Client(),
        _secrets = secrets ?? SecretStore();

  static const _providerPref = 'numo.ai.provider';
  static const _endpointPref = 'numo.ai.endpoint';
  static const _keyPref = 'numo.ai.key';
  static const _modelPref = 'numo.ai.model';

  final http.Client _client;

  /// Ключ — секрет: живёт в системном хранилище (ADR-0013),
  /// а не в plaintext-prefs, как endpoint и модель.
  final SecretStore _secrets;

  Future<AiProvider> get provider async {
    final raw =
        (await SharedPreferences.getInstance()).getString(_providerPref);
    return AiProvider.values
        .firstWhere((p) => p.name == raw, orElse: () => AiProvider.anthropic);
  }

  Future<String?> get apiKey => _secrets.read(_keyPref);

  Future<String> get endpoint async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_endpointPref) ??
        aiProviderDefaults(await provider).endpoint;
  }

  Future<String> get model async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modelPref) ??
        aiProviderDefaults(await provider).model;
  }

  /// Готов ли сервис к запросу: ключ есть либо провайдеру он не нужен.
  Future<bool> get configured async {
    final p = await provider;
    if (!aiProviderDefaults(p).keyRequired) {
      return (await endpoint).isNotEmpty;
    }
    final key = await apiKey;
    return key != null && key.isNotEmpty;
  }

  Future<void> configure({
    required AiProvider provider,
    required String endpoint,
    required String key,
    required String model,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerPref, provider.name);
    Future<void> setOrRemove(String pref, String value) async =>
        value.isEmpty ? await prefs.remove(pref) : await prefs.setString(pref, value);
    await setOrRemove(_endpointPref, endpoint);
    await setOrRemove(_modelPref, model);
    if (key.isEmpty) {
      await _secrets.delete(_keyPref);
    } else {
      await _secrets.write(_keyPref, key);
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
    final activeProvider = await provider;
    final defaults = aiProviderDefaults(activeProvider);
    final key = await apiKey;
    if (defaults.keyRequired && (key == null || key.isEmpty)) {
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

    final isAnthropic = activeProvider == AiProvider.anthropic;
    final headers = <String, String>{
      'content-type': 'application/json',
      if (isAnthropic) 'x-api-key': key!,
      if (isAnthropic) 'anthropic-version': '2023-06-01',
      if (!isAnthropic && key != null && key.isNotEmpty)
        'authorization': 'Bearer $key',
    };
    // Тело совпадает для Messages API и chat/completions:
    // model + max_tokens + messages читаются одинаково.
    final body = {
      'model': await model,
      'max_tokens': 1200,
      'messages': [
        {'role': 'user', 'content': prompt + jsonEncode(summary)}
      ],
    };
    final response = await _client
        .post(
          Uri.parse(await endpoint),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));

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
    String? text;
    if (isAnthropic) {
      final content = json['content'] as List?;
      text = content
          ?.whereType<Map<String, dynamic>>()
          .where((block) => block['type'] == 'text')
          .map((block) => block['text'] as String)
          .join('\n');
    } else {
      final choices = json['choices'] as List?;
      final message = choices != null && choices.isNotEmpty
          ? (choices.first as Map<String, dynamic>)['message']
          : null;
      if (message is Map<String, dynamic>) {
        text = message['content'] as String?;
      }
    }
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
