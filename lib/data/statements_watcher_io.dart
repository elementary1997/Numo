import 'dart:io';

import 'statement_types.dart';

/// dart:io-реализация: файлы выписок новее отметки последнего скана.
Future<List<FoundStatement>> listNewStatements(
    String dir, DateTime? since) async {
  const extensions = {'.csv', '.ofx', '.xlsx', '.pdf', '.txt'};
  final directory = Directory(dir);
  if (!await directory.exists()) return const [];
  final result = <FoundStatement>[];
  await for (final entity in directory.list(followLinks: false)) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    if (dot == -1 || !extensions.contains(name.substring(dot).toLowerCase())) {
      continue;
    }
    final stat = await entity.stat();
    if (since != null && !stat.modified.isAfter(since)) continue;
    result.add(FoundStatement(entity.path, name));
  }
  result.sort((a, b) => a.name.compareTo(b.name));
  return result;
}
