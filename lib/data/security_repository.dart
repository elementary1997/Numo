import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PIN-защита приложения. Хранятся только соль и SHA-256(соль+PIN)
/// (ADR-0008) — сам PIN не восстановим.
class SecurityRepository {
  SecurityRepository._(this._prefs);

  static const _saltKey = 'numo.pin.salt';
  static const _hashKey = 'numo.pin.hash';

  final SharedPreferences _prefs;

  static Future<SecurityRepository> open() async {
    return SecurityRepository._(await SharedPreferences.getInstance());
  }

  bool get hasPin => _prefs.containsKey(_hashKey);

  Future<void> setPin(String pin) async {
    final saltBytes =
        List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final salt = base64Encode(saltBytes);
    await _prefs.setString(_saltKey, salt);
    await _prefs.setString(_hashKey, _hash(salt, pin));
  }

  bool verify(String pin) {
    final salt = _prefs.getString(_saltKey);
    final hash = _prefs.getString(_hashKey);
    if (salt == null || hash == null) return false;
    return _hash(salt, pin) == hash;
  }

  Future<void> clear() async {
    await _prefs.remove(_saltKey);
    await _prefs.remove(_hashKey);
  }

  static String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}
