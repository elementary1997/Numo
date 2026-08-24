import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Автообновление desktop-приложения (ADR-0010): скачиваем архив
/// релиза, распаковываем во временную папку и запускаем отсоединённый
/// скрипт, который после выхода приложения подменяет файлы и
/// перезапускает Numo. Скрипт использует системные распаковщики
/// (tar/ditto/PowerShell), чтобы сохранить права и symlink'и.
class SelfUpdater {
  static bool get supported =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Папка установки: для macOS — путь к Numo.app, иначе папка бинаря.
  static String installPath() {
    final executable = File(Platform.resolvedExecutable);
    if (Platform.isMacOS) {
      // .../Numo.app/Contents/MacOS/numo → .../Numo.app
      return executable.parent.parent.parent.path;
    }
    return executable.parent.path;
  }

  /// Скачивает [assetUrl], готовит установку и завершает приложение.
  /// [onProgress] — доля скачанного (0..1) или null, пока размер
  /// неизвестен. При любой ошибке бросает исключение — вызывающий
  /// показывает fallback со ссылкой.
  static Future<void> downloadAndInstall(
    String assetUrl, {
    void Function(double? progress)? onProgress,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final work =
        await Directory.systemTemp.createTemp('numo-update-');
    final archivePath =
        '${work.path}/${Uri.parse(assetUrl).pathSegments.last}';

    // Потоковое скачивание с прогрессом.
    final request = http.Request('GET', Uri.parse(assetUrl));
    final response = await httpClient.send(request);
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final total = response.contentLength;
    final sink = File(archivePath).openWrite();
    var received = 0;
    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      onProgress?.call(total == null ? null : received / total);
    }
    await sink.close();

    // Распаковка системными средствами: сохраняет права и symlink'и.
    final extractDir = Directory('${work.path}/extracted')..createSync();
    final ProcessResult unpack;
    if (Platform.isWindows) {
      unpack = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        'Expand-Archive -LiteralPath "$archivePath" -DestinationPath "${extractDir.path}" -Force',
      ]);
    } else if (Platform.isMacOS) {
      unpack = await Process.run(
          'ditto', ['-x', '-k', archivePath, extractDir.path]);
    } else {
      unpack = await Process.run(
          'tar', ['xzf', archivePath, '-C', extractDir.path]);
    }
    if (unpack.exitCode != 0) {
      throw Exception('unpack failed: ${unpack.stderr}');
    }

    final target = installPath();
    final pid = pid_();

    if (Platform.isWindows) {
      final script = File('${work.path}/update.bat');
      script.writeAsStringSync('''
@echo off
:waitloop
tasklist /FI "PID eq $pid" 2>NUL | find "$pid" >NUL
if not errorlevel 1 (
  timeout /T 1 /NOBREAK >NUL
  goto waitloop
)
robocopy "${extractDir.path}" "$target" /E /IS /IT >NUL
start "" "$target\\numo.exe"
''');
      await Process.start(
        'cmd',
        ['/c', script.path],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
    } else if (Platform.isMacOS) {
      // В архиве лежит Numo.app.
      final newApp = '${extractDir.path}/Numo.app';
      final script = File('${work.path}/update.sh');
      script.writeAsStringSync('''
#!/bin/sh
while kill -0 $pid 2>/dev/null; do sleep 0.5; done
rm -rf "$target"
ditto "$newApp" "$target"
open "$target"
''');
      await Process.run('chmod', ['+x', script.path]);
      await Process.start(script.path, [],
          mode: ProcessStartMode.detached);
    } else {
      final script = File('${work.path}/update.sh');
      script.writeAsStringSync('''
#!/bin/sh
while kill -0 $pid 2>/dev/null; do sleep 0.5; done
cp -rf "${extractDir.path}/." "$target/"
chmod +x "$target/numo"
"$target/numo" >/dev/null 2>&1 &
''');
      await Process.run('chmod', ['+x', script.path]);
      await Process.start(script.path, [],
          mode: ProcessStartMode.detached);
    }

    // Скрипт ждёт нашего выхода — выходим.
    exit(0);
  }

  static int pid_() => pid;
}
