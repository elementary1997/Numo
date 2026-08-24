import 'dart:io';

/// Файловые операции синхронизации: реализация для платформ с dart:io.
const bool syncSupported = true;

Future<void> writeSyncFile(String path, String content) async {
  // Запись через временный файл — облачный клиент не увидит недописанный.
  final tmp = File('$path.tmp');
  await tmp.writeAsString(content, flush: true);
  await tmp.rename(path);
}

Future<String?> readSyncFile(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsString();
}
