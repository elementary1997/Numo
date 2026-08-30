/// Web: автообновление не применимо — страница всегда свежая.
class SelfUpdater {
  static bool get supported => false;

  static Future<void> downloadAndInstall(
    String assetUrl, {
    void Function(double? progress)? onProgress,
    Object? client,
  }) async {
    throw UnsupportedError('Self-update is not available on web');
  }

  static bool canWriteToInstallDir() => false;
}
