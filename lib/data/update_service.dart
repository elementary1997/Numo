import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Информация о доступном обновлении.
class UpdateInfo {
  const UpdateInfo({required this.version, required this.url});

  final String version;
  final String url;
}

/// Проверка обновлений через GitHub Releases (ADR-0010): анонимный GET
/// `releases/latest` не чаще раза в сутки, сравнение semver с версией
/// приложения. Любая ошибка сети приравнивается к «обновлений нет».
class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const _lastCheckKey = 'numo.updates.lastCheck';
  static const _cachedVersionKey = 'numo.updates.latestVersion';
  static const _cachedUrlKey = 'numo.updates.latestUrl';
  static const _disabledKey = 'numo.updates.disabled';

  static final _url = Uri.parse(
      'https://api.github.com/repos/elementary1997/Numo/releases/latest');

  final http.Client _client;

  Future<bool> get autoCheckEnabled async =>
      !((await SharedPreferences.getInstance()).getBool(_disabledKey) ??
          false);

  Future<void> setAutoCheckEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      await prefs.remove(_disabledKey);
    } else {
      await prefs.setBool(_disabledKey, true);
    }
  }

  Future<String> currentVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  /// null — обновлений нет (или проверка выключена/недоступна).
  /// [force] игнорирует выключатель и суточный кэш (ручная проверка).
  Future<UpdateInfo?> check({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!force && (prefs.getBool(_disabledKey) ?? false)) return null;

    final lastCheckRaw = prefs.getString(_lastCheckKey);
    final lastCheck =
        lastCheckRaw == null ? null : DateTime.tryParse(lastCheckRaw);
    final cacheFresh = lastCheck != null &&
        DateTime.now().difference(lastCheck) < const Duration(hours: 24);

    String? latestVersion;
    String? latestUrl;
    if (!force && cacheFresh) {
      latestVersion = prefs.getString(_cachedVersionKey);
      latestUrl = prefs.getString(_cachedUrlKey);
    } else {
      try {
        final response = await _client.get(_url, headers: {
          'Accept': 'application/vnd.github+json',
        }).timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) return null;
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        latestVersion =
            (json['tag_name'] as String?)?.replaceFirst('v', '');
        latestUrl = json['html_url'] as String?;
        if (latestVersion != null && latestUrl != null) {
          await prefs.setString(_cachedVersionKey, latestVersion);
          await prefs.setString(_cachedUrlKey, latestUrl);
          await prefs.setString(
              _lastCheckKey, DateTime.now().toIso8601String());
        }
      } catch (_) {
        return null; // офлайн — молчим
      }
    }

    if (latestVersion == null || latestUrl == null) return null;
    final current = await currentVersion();
    if (!isNewerVersion(latestVersion, current)) return null;
    return UpdateInfo(version: latestVersion, url: latestUrl);
  }

  /// Сравнение semver: `candidate` новее `current`?
  static bool isNewerVersion(String candidate, String current) {
    List<int> parse(String v) => v
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final a = parse(candidate);
    final b = parse(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}
