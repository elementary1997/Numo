import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Хранилище секретов (ADR-0013): системное секьюрное хранилище через
/// flutter_secure_storage — Keychain (Apple), Keystore (Android),
/// DPAPI (Windows), Secret Service (Linux), WebCrypto (web) — с
/// фолбэком в shared_preferences там, где оно недоступно (Linux без
/// запущенного Secret Service и т.п.). Значение из старого
/// plaintext-хранения переносится в секьюрное при первом чтении.
class SecretStore {
  SecretStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // Легаси-кейчейн вместо data protection keychain: не
              // требует entitlement «Keychain Sharing», которого нет
              // у ad-hoc подписанных macOS-сборок (см. release.yml).
              mOptions: MacOsOptions(usesDataProtectionKeychain: false),
            );

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
    } catch (_) {
      // Секьюрное хранилище недоступно — читаем фолбэк.
    }
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(key);
    if (legacy != null) {
      try {
        await _storage.write(key: key, value: legacy);
        await prefs.remove(key);
      } catch (_) {
        // Перенести не вышло — значение остаётся в prefs до
        // следующей попытки.
      }
    }
    return legacy;
  }

  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await _storage.write(key: key, value: value);
      await prefs.remove(key);
      return;
    } catch (_) {
      // Секьюрное хранилище недоступно — честный фолбэк в prefs,
      // как хранилось до ADR-0013.
    }
    await prefs.setString(key, value);
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Даже если кейчейн недоступен, фолбэк-копию убираем всегда.
    }
    await (await SharedPreferences.getInstance()).remove(key);
  }
}
