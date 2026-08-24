/// Файловые операции синхронизации: web-заглушка (ADR-0008 —
/// на web файловый sync недоступен, остаётся ручной экспорт/импорт).
const bool syncSupported = false;

Future<void> writeSyncFile(String path, String content) async {
  throw UnsupportedError('Файловая синхронизация недоступна на web');
}

Future<String?> readSyncFile(String path) async => null;
