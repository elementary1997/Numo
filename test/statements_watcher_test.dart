import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/statements_watcher.dart';

void main() {
  test('находит только новые файлы выписок поддерживаемых форматов',
      () async {
    final tmp = await Directory.systemTemp.createTemp('numo-statements');
    addTearDown(() => tmp.delete(recursive: true));

    File('${tmp.path}/old.csv').writeAsStringSync('a;b');
    final marker = DateTime.now();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    File('${tmp.path}/fresh.csv').writeAsStringSync('c;d');
    File('${tmp.path}/statement.pdf').writeAsStringSync('%PDF-1.4');
    File('${tmp.path}/notes.docx').writeAsStringSync('x'); // мимо

    final all = await StatementsWatcher.listNewStatements(tmp.path, null);
    expect(all.map((f) => f.name),
        containsAll(['old.csv', 'fresh.csv', 'statement.pdf']));
    expect(all.any((f) => f.name == 'notes.docx'), isFalse);

    final fresh =
        await StatementsWatcher.listNewStatements(tmp.path, marker);
    expect(fresh.map((f) => f.name),
        containsAll(['fresh.csv', 'statement.pdf']));
    expect(fresh.any((f) => f.name == 'old.csv'), isFalse);
  });
}
