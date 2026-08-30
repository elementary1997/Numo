import 'dart:async';
import 'dart:convert';
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
      return macAppPathFor(executable.parent.parent.parent.path);
    }
    return executable.parent.path;
  }

  /// Куда ставить обновление на macOS. Если приложение скачано
  /// браузером (с карантином) и запущено без переноса через Finder,
  /// Gatekeeper выполняет его из случайного read-only пути
  /// (App Translocation) — заменять надо не его, а «настоящую» копию,
  /// поэтому в этом случае ставим в /Applications/Numo.app.
  static String macAppPathFor(String appPath) {
    if (appPath.contains('/AppTranslocation/')) {
      return '/Applications/Numo.app';
    }
    return appPath;
  }

  /// Куда пишется ход подмены файлов — этот путь показывается
  /// пользователю, если обновление не встало.
  static String get updateLogPath => Platform.isWindows
      ? '${Platform.environment['TEMP'] ?? r'C:\Windows\Temp'}\\numo-update.log'
      : '/tmp/numo-update.log';

  /// Есть ли право писать в папку установки. На Windows приложение,
  /// распакованное в Program Files, обновиться на месте не может —
  /// лучше сказать об этом до скачивания архива, чем после.
  static bool canWriteToInstallDir() {
    if (!Platform.isWindows) return true;
    try {
      final probe = File('${installPath()}/.numo-write-probe');
      probe.writeAsStringSync('');
      probe.deleteSync();
      return true;
    } catch (_) {
      return false;
    }
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
      // Источником может оказаться вложенная папка архива.
      final source = resolveSourceDir(extractDir.path, 'numo.exe');
      final script = File('${work.path}/update.ps1');
      // PowerShell вместо .bat: cmd читает файл в кодировке консоли
      // (в русской Windows — CP866), а Dart пишет UTF-8, поэтому путь
      // вида C:\Users\Павел\AppData\Local\Temp\… приезжал битым и
      // обновление молча не вставало. UTF-8 с BOM PowerShell понимает
      // при любой локали.
      script.writeAsBytesSync([
        0xEF, 0xBB, 0xBF,
        ...utf8.encode(
            windowsUpdateScript(pid: pid, source: source, target: target)),
      ]);
      await Process.start(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-WindowStyle',
          'Hidden',
          '-File',
          script.path,
        ],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
    } else if (Platform.isMacOS) {
      // В архиве лежит Numo.app.
      final newApp = '${extractDir.path}/Numo.app';
      if (!Directory(newApp).existsSync()) {
        throw Exception('Numo.app not found in downloaded archive');
      }
      // Лог всей подмены — для диагностики, если обновление не встало.
      final script = File('${work.path}/update.sh');
      script.writeAsStringSync('''
#!/bin/sh
exec > /tmp/numo-update.log 2>&1
set -x
while kill -0 $pid 2>/dev/null; do sleep 0.5; done
rm -rf "$target"
ditto "$newApp" "$target"
xattr -cr "$target" || true
open "$target"
''');
      await Process.run('chmod', ['+x', script.path]);
      await Process.start(script.path, [],
          mode: ProcessStartMode.detached);
    } else {
      final source = resolveSourceDir(extractDir.path, 'numo');
      final script = File('${work.path}/update.sh');
      script.writeAsStringSync('''
#!/bin/sh
exec > /tmp/numo-update.log 2>&1
set -x
while kill -0 $pid 2>/dev/null; do sleep 0.5; done
cp -rf "$source/." "$target/"
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

  /// Корень распакованного архива: папка, где реально лежит [marker].
  /// Архив может содержать файлы в корне, а может — во вложенной папке;
  /// копировать нужно содержимое той, где лежит исполняемый файл.
  static String resolveSourceDir(String extractedPath, String marker) {
    if (File('$extractedPath/$marker').existsSync()) return extractedPath;
    final nested = Directory(extractedPath)
        .listSync()
        .whereType<Directory>()
        .where((d) => File('${d.path}/$marker').existsSync())
        .toList();
    return nested.length == 1 ? nested.single.path : extractedPath;
  }

  /// PowerShell-скрипт подмены файлов на Windows. Вынесен отдельно,
  /// чтобы проверяться тестом: ошибка здесь видна только на живой
  /// машине после выхода приложения.
  static String windowsUpdateScript({
    required int pid,
    required String source,
    required String target,
  }) {
    String quote(String path) => "'${path.replaceAll("'", "''")}'";
    return '''
\$ErrorActionPreference = 'Stop'
\$log = Join-Path \$env:TEMP 'numo-update.log'
Start-Transcript -Path \$log -Force | Out-Null
try {
  # Ждём, пока закроется само приложение: файлы заняты, пока оно живо.
  Wait-Process -Id $pid -Timeout 120 -ErrorAction SilentlyContinue
  # Даём Windows отпустить дескрипторы после выхода процесса.
  Start-Sleep -Milliseconds 700
  \$source = ${quote(source)}
  \$target = ${quote(target)}
  Write-Output "source: \$source"
  Write-Output "target: \$target"
  # robocopy надёжнее Copy-Item на деревьях каталогов и умеет
  # повторять попытки, если файл ещё занят.
  \$robo = Start-Process -FilePath 'robocopy.exe' -ArgumentList @(
      \$source, \$target, '/E', '/IS', '/IT', '/R:3', '/W:1', '/NFL', '/NDL', '/NP'
    ) -Wait -PassThru -WindowStyle Hidden
  Write-Output "robocopy exit code: \$(\$robo.ExitCode)"
  # У robocopy успех — это 0..7; 8 и выше означают, что часть файлов
  # скопировать не удалось.
  if (\$robo.ExitCode -ge 8) { throw "robocopy failed: \$(\$robo.ExitCode)" }
  Write-Output 'update: files copied'
} catch {
  Write-Output "update failed: \$_"
} finally {
  Stop-Transcript | Out-Null
  # Приложение запускаем в любом случае — даже если подмена не удалась,
  # пользователь не должен остаться без Numo.
  Start-Process -FilePath (Join-Path ${quote(target)} 'numo.exe')
}
''';
  }
}
