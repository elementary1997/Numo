import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Снимок курсов: рублей за единицу валюты.
class RatesSnapshot {
  const RatesSnapshot({required this.rates, required this.fetchedAt});

  final Map<String, double> rates;
  final DateTime fetchedAt;

  double? rubFor(String currency) =>
      currency == 'RUB' ? 1 : rates[currency];
}

/// Курсы валют ЦБ РФ с суточным кэшем в shared_preferences (ADR-0007).
/// Единственный сетевой вызов приложения; любая ошибка сети деградирует
/// до кэша, а без кэша — до отсутствия конвертации.
class RatesRepository {
  RatesRepository({http.Client? client}) : _client = client ?? http.Client();

  static const _cacheKey = 'numo.rates.v1';
  static final _url = Uri.parse('https://www.cbr.ru/scripts/XML_daily.asp');

  final http.Client _client;

  Future<RatesSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = _readCache(prefs);
    final isFresh = cached != null &&
        DateTime.now().difference(cached.fetchedAt) <
            const Duration(hours: 24);
    if (isFresh) return cached;

    try {
      final response =
          await _client.get(_url).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return cached;
      final rates = parseCbrXml(response.body);
      if (rates.isEmpty) return cached;
      final snapshot =
          RatesSnapshot(rates: rates, fetchedAt: DateTime.now());
      await prefs.setString(
          _cacheKey,
          jsonEncode({
            'fetchedAt': snapshot.fetchedAt.toIso8601String(),
            'rates': rates,
          }));
      return snapshot;
    } catch (_) {
      return cached; // офлайн — живём на последнем кэше
    }
  }

  static RatesSnapshot? _readCache(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return RatesSnapshot(
        rates: (json['rates'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Парсит дневной XML ЦБ: рублей за одну единицу валюты.
  /// Читаются только ASCII-поля — кодировка windows-1251 не мешает.
  static Map<String, double> parseCbrXml(String xml) {
    final result = <String, double>{};
    final valute = RegExp(
      r'<CharCode>([A-Z]{3})</CharCode>\s*'
      r'<Nominal>(\d+)</Nominal>\s*'
      r'<Name>.*?</Name>\s*'
      r'<Value>([\d,\.]+)</Value>',
      dotAll: true,
    );
    for (final match in valute.allMatches(xml)) {
      final code = match.group(1)!;
      final nominal = int.parse(match.group(2)!);
      final value = double.parse(match.group(3)!.replaceAll(',', '.'));
      if (nominal > 0) result[code] = value / nominal;
    }
    return result;
  }
}
