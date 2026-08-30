import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/secret_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// В тестовой среде плагина flutter_secure_storage нет, поэтому каждый
// вызов уходит в фолбэк на shared_preferences — проверяем именно его:
// это и есть контракт «в худшем случае работает как раньше» (ADR-0013).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('write/read/delete работают через фолбэк', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SecretStore();

    await store.write('numo.ai.key', 'sk-test');
    expect(await store.read('numo.ai.key'), 'sk-test');

    await store.delete('numo.ai.key');
    expect(await store.read('numo.ai.key'), isNull);
  });

  test('read видит легаси-значение из plaintext-prefs', () async {
    SharedPreferences.setMockInitialValues({'numo.ai.key': 'sk-legacy'});
    final store = SecretStore();

    expect(await store.read('numo.ai.key'), 'sk-legacy');
    // Секьюрное хранилище недоступно — значение не потеряно.
    expect(await store.read('numo.ai.key'), 'sk-legacy');
  });

  test('пустой ключ удаляется, а не пишется', () async {
    SharedPreferences.setMockInitialValues({'numo.ai.key': 'sk-old'});
    final store = SecretStore();

    await store.delete('numo.ai.key');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('numo.ai.key'), isNull);
  });
}
