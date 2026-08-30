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

/// Файлы папки, чьи имена начинаются с [prefix] и кончаются на `.json`
/// — файлы участников общего счёта (ADR-0014).
Future<List<String>> listSyncFiles(String dir, String prefix) async {
  final directory = Directory(dir);
  if (!await directory.exists()) return const [];
  final result = <String>[];
  await for (final entity in directory.list(followLinks: false)) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (name.startsWith(prefix) && name.endsWith('.json')) {
      result.add(entity.path);
    }
  }
  result.sort();
  return result;
}
