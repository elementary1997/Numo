import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'backup.dart';
import 'sync_file_stub.dart' if (dart.library.io) 'sync_file_io.dart'
    as sync_file;

/// Синхронизация через папку пользовательского облака (ADR-0008):
/// полный бэкап пишется в `numo-sync.json` после каждого изменения
/// (с дебаунсом), при запуске более новый файл предлагается принять.
class SyncService {
  SyncService._(this._prefs);

  static const fileName = 'numo-sync.json';
  static const _dirKey = 'numo.sync.dir';
  static const _lastWriteKey = 'numo.sync.lastWrite';

  final SharedPreferences _prefs;
  Timer? _debounce;

  static Future<SyncService> open() async {
    return SyncService._(await SharedPreferences.getInstance());
  }

  static bool get supported => sync_file.syncSupported;

  String? get directory => _prefs.getString(_dirKey);

  DateTime? get lastWrite {
    final raw = _prefs.getString(_lastWriteKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  String get _filePath => '$directory/$fileName';

  Future<void> setDirectory(String? dir) async {
    if (dir == null) {
      await _prefs.remove(_dirKey);
      await _prefs.remove(_lastWriteKey);
    } else {
      await _prefs.setString(_dirKey, dir);
    }
  }

  /// Планирует запись бэкапа с дебаунсом — серия быстрых изменений
  /// превращается в одну запись файла.
  void scheduleWrite(BackupData Function() collect) {
    if (!supported || directory == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => _write(collect()));
  }

  Future<void> _write(BackupData data) async {
    try {
      final json = Backup.encode(data);
      await sync_file.writeSyncFile(_filePath, json);
      final exportedAt =
          (jsonDecode(json) as Map<String, dynamic>)['exportedAt'] as String;
      await _prefs.setString(_lastWriteKey, exportedAt);
    } catch (_) {
      // Папка недоступна (облако отмонтировано) — не роняем приложение;
      // следующая запись попробует снова.
    }
  }

  /// Немедленная запись (используется при включении синхронизации).
  Future<void> writeNow(BackupData data) => _write(data);

  /// Проверяет при запуске, нет ли в папке данных новее локальных.
  /// Возвращает (data, exportedAt) или null.
  Future<(BackupData, DateTime)?> checkForNewer() async {
    if (!supported || directory == null) return null;
    try {
      final raw = await sync_file.readSyncFile(_filePath);
      if (raw == null) return null;
      final exportedAtRaw =
          (jsonDecode(raw) as Map<String, dynamic>)['exportedAt'] as String?;
      final exportedAt =
          exportedAtRaw == null ? null : DateTime.tryParse(exportedAtRaw);
      if (exportedAt == null) return null;
      final last = lastWrite;
      if (last != null &&
          !exportedAt.isAfter(last.add(const Duration(seconds: 1)))) {
        return null; // файл наш собственный или старее
      }
      return (Backup.decode(raw), exportedAt);
    } catch (_) {
      return null;
    }
  }

  /// Отметить, что данные из файла приняты.
  Future<void> markAccepted(DateTime exportedAt) =>
      _prefs.setString(_lastWriteKey, exportedAt.toIso8601String());
}
