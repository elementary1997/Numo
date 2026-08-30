import 'reminders.dart';

/// Платформы без локальных уведомлений (web, Windows): переключатель
/// в настройках не показывается, вызовы ничего не делают.
const bool notificationsSupported = false;

Future<bool> initNotifications() async => false;

Future<bool> requestNotificationPermission() async => false;

Future<void> scheduleReminders(List<Reminder> reminders) async {}

Future<void> showNow({
  required int id,
  required String title,
  required String body,
}) async {}

Future<void> cancelAllReminders() async {}
