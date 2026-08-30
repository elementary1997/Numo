import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminders.dart';

/// Локальные уведомления (ADR-0015). Планирование поддерживают
/// Android, iOS, macOS и Linux; на Windows пакета нет.
bool get notificationsSupported =>
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS ||
    Platform.isLinux;

final _plugin = FlutterLocalNotificationsPlugin();
var _initialized = false;

/// Готовит плагин и таймзоны. Возвращает false, если платформа не
/// поддерживается или инициализация не удалась — вызывающий тогда
/// просто не показывает переключатель.
Future<bool> initNotifications() async {
  if (!notificationsSupported) return false;
  if (_initialized) return true;
  try {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Numo'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
    return true;
  } catch (_) {
    return false;
  }
}

/// Спрашивает разрешение — по делу, при включении переключателя.
Future<bool> requestNotificationPermission() async {
  if (!await initNotifications()) return false;
  try {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      final darwin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final granted = await (darwin?.requestPermissions(
              alert: true, badge: true, sound: true) ??
          macos?.requestPermissions(alert: true, badge: true, sound: true));
      return granted ?? true;
    }
    return true;
  } catch (_) {
    return false;
  }
}

const _details = NotificationDetails(
  android: AndroidNotificationDetails(
    'numo.reminders',
    'Напоминания',
    channelDescription: 'Регулярные платежи и перерасход бюджета',
    importance: Importance.defaultImportance,
  ),
  iOS: DarwinNotificationDetails(),
  macOS: DarwinNotificationDetails(),
  linux: LinuxNotificationDetails(),
);

/// Перепланирует все напоминания: прежние снимаются целиком — так
/// проще и надёжнее, чем вычислять разницу.
Future<void> scheduleReminders(List<Reminder> reminders) async {
  if (!await initNotifications()) return;
  try {
    await cancelAllReminders();
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body.isEmpty ? null : reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.when, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  } catch (_) {
    // Нет разрешения или платформа отказала — приложение работает
    // как работало, просто без напоминаний.
  }
}

Future<void> showNow({
  required int id,
  required String title,
  required String body,
}) async {
  if (!await initNotifications()) return;
  try {
    await _plugin.show(
        id: id, title: title, body: body, notificationDetails: _details);
  } catch (_) {
    // См. выше: уведомления — приятное дополнение, не обязательство.
  }
}

Future<void> cancelAllReminders() async {
  if (!_initialized) return;
  try {
    await _plugin.cancelAll();
  } catch (_) {
    // Нечего отменять.
  }
}
