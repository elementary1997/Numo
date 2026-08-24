import 'package:shared_preferences/shared_preferences.dart';

import 'statement_types.dart';
import 'statements_watcher_stub.dart'
    if (dart.library.io) 'statements_watcher_io.dart' as impl;

export 'statement_types.dart';

/// Сканер папки выписок (этап 2 банковской интеграции,
/// docs/bank-integrations.md): при запуске находит файлы выписок,
/// появившиеся после последнего сканирования.
class StatementsWatcher {
  static const _dirKey = 'numo.statements.dir';
  static const _lastScanKey = 'numo.statements.lastScan';

  /// Новые файлы с прошлого сканирования; отметка времени обновляется.
  static Future<List<FoundStatement>> scan() async {
    final prefs = await SharedPreferences.getInstance();
    final dir = prefs.getString(_dirKey);
    if (dir == null) return const [];
    final lastRaw = prefs.getString(_lastScanKey);
    final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
    final found = await listNewStatements(dir, last);
    await prefs.setString(_lastScanKey, DateTime.now().toIso8601String());
    return found;
  }

  static Future<List<FoundStatement>> listNewStatements(
          String dir, DateTime? since) =>
      impl.listNewStatements(dir, since);
}
