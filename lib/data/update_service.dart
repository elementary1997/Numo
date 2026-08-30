import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'platform_name_stub.dart'
    if (dart.library.io) 'platform_name_io.dart';

/// Информация о доступном обновлении.
class UpdateInfo {
  const UpdateInfo({required this.version, required this.url, this.assetUrl});

  final String version;

  /// Страница релиза (fallback, если автообновление недоступно).
  final String url;

  /// Прямая ссылка на архив сборки для текущей платформы.
  final String? assetUrl;
}

/// Имя архива релиза для текущей платформы; null — автообновление
/// на этой платформе не поддерживается (web).
String? platformAssetName({String? platformOverride}) {
  final platform = platformOverride ?? currentPlatformName();
  return switch (platform) {
    'windows' => 'numo-windows-x64.zip',
    'macos' => 'numo-macos.zip',
    'linux' => 'numo-linux-x64.tar.gz',
    _ => null,
  };
}

/// Результат ручной проверки: доступна версия / всё актуально /
/// проверить не удалось (нет сети и т.п.).
enum UpdateCheckStatus { available, upToDate, failed }

class UpdateCheckResult {
  const UpdateCheckResult(this.status, [this.info]);

  final UpdateCheckStatus status;
  final UpdateInfo? info;
}

/// Проверка обновлений через GitHub Releases (ADR-0010): анонимный GET
/// `releases/latest` не чаще раза в сутки, сравнение semver с версией
/// приложения. Любая ошибка сети приравнивается к «обновлений нет».
class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const _lastCheckKey = 'numo.updates.lastCheck';
  static const _cachedVersionKey = 'numo.updates.latestVersion';
  static const _cachedUrlKey = 'numo.updates.latestUrl';
  static const _cachedAssetKey = 'numo.updates.latestAsset';
  static const _disabledKey = 'numo.updates.disabled';
  static const _pendingKey = 'numo.updates.pendingVersion';
  static const _dismissedKey = 'numo.updates.dismissedVersion';

  /// Свежесть кэша проверки. Час, а не сутки: суточный кэш скрывал
  /// свежий релиз до завтра даже после перезапуска приложения.
  /// Анонимный лимит GitHub API — 60 запросов/час с IP, один GET
  /// в час незаметен.
  static const cacheTtl = Duration(hours: 1);

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

  /// Версия, о которой пользователь сказал «позже»: баннер про неё
  /// больше не показывается, но следующий релиз снова напомнит о себе.
  Future<String?> get dismissedVersion async =>
      (await SharedPreferences.getInstance()).getString(_dismissedKey);

  Future<void> dismissVersion(String version) async =>
      (await SharedPreferences.getInstance())
          .setString(_dismissedKey, version);

  /// Помечает, что установка [version] запущена. Подмена файлов идёт
  /// уже после выхода приложения, поэтому её провал виден только по
  /// тому, что после перезапуска версия осталась прежней.
  Future<void> markPending(String version) async =>
      (await SharedPreferences.getInstance())
          .setString(_pendingKey, version);

  /// Версия, обновление до которой не встало; null — всё в порядке.
  /// Отметку снимает в любом случае — сообщение показывается один раз.
  Future<String?> takeFailedUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString(_pendingKey);
    if (pending == null) return null;
    await prefs.remove(_pendingKey);
    final current = await currentVersion();
    return isNewerVersion(pending, current) ? pending : null;
  }

  /// Ручная проверка с различением «нет сети» и «нет обновлений».
  Future<UpdateCheckResult> checkManually() async {
    try {
      final response = await _client.get(_url, headers: {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return const UpdateCheckResult(UpdateCheckStatus.failed);
      }
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final version = (json['tag_name'] as String?)?.replaceFirst('v', '');
      final url = json['html_url'] as String?;
      if (version == null || url == null) {
        return const UpdateCheckResult(UpdateCheckStatus.failed);
      }
      final current = await currentVersion();
      if (isNewerVersion(version, current)) {
        return UpdateCheckResult(
            UpdateCheckStatus.available,
            UpdateInfo(
              version: version,
              url: url,
              assetUrl: _assetUrlFrom(json),
            ));
      }
      return const UpdateCheckResult(UpdateCheckStatus.upToDate);
    } catch (_) {
      return const UpdateCheckResult(UpdateCheckStatus.failed);
    }
  }

  /// null — обновлений нет (или проверка выключена/недоступна).
  /// [force] игнорирует выключатель и суточный кэш (ручная проверка).
  Future<UpdateInfo?> check({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!force && (prefs.getBool(_disabledKey) ?? false)) return null;

    final lastCheckRaw = prefs.getString(_lastCheckKey);
    final lastCheck =
        lastCheckRaw == null ? null : DateTime.tryParse(lastCheckRaw);
    final cacheFresh =
        lastCheck != null && DateTime.now().difference(lastCheck) < cacheTtl;

    String? latestVersion;
    String? latestUrl;
    String? latestAsset;
    if (!force && cacheFresh) {
      latestVersion = prefs.getString(_cachedVersionKey);
      latestUrl = prefs.getString(_cachedUrlKey);
      latestAsset = prefs.getString(_cachedAssetKey);
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
        latestAsset = _assetUrlFrom(json);
        if (latestVersion != null && latestUrl != null) {
          await prefs.setString(_cachedVersionKey, latestVersion);
          await prefs.setString(_cachedUrlKey, latestUrl);
          // Без ссылки на архив кнопка «Обновить» открывала бы
          // страницу релиза вместо самообновления.
          if (latestAsset == null) {
            await prefs.remove(_cachedAssetKey);
          } else {
            await prefs.setString(_cachedAssetKey, latestAsset);
          }
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
    return UpdateInfo(
        version: latestVersion, url: latestUrl, assetUrl: latestAsset);
  }

  /// Ссылка на архив текущей платформы из JSON релиза.
  static String? _assetUrlFrom(Map<String, dynamic> release) {
    final wanted = platformAssetName();
    if (wanted == null) return null;
    final assets = release['assets'] as List?;
    if (assets == null) return null;
    for (final asset in assets.whereType<Map<String, dynamic>>()) {
      if (asset['name'] == wanted) {
        return asset['browser_download_url'] as String?;
      }
    }
    return null;
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
