import '../models/recurring.dart';

/// О чём напомнить: заголовок, текст и когда показать.
/// Отдельно от плагина уведомлений — чтобы правила «о чём и когда»
/// проверялись тестами без платформы (ADR-0015).
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
  });

  /// Стабильный числовой id: плагин уведомлений адресует их числами,
  /// а перепланирование должно перезаписывать прежнее напоминание.
  final int id;
  final String title;
  final String body;
  final DateTime when;
}

/// Во сколько напоминать накануне платежа.
const reminderHour = 10;

/// Напоминания о регулярных платежах на ближайшие [horizonDays] дней:
/// накануне даты списания, в [reminderHour] часов.
///
/// [format] превращает сумму правила в текст — форматирование денег
/// живёт в UI-слое и зависит от локали.
List<Reminder> upcomingRecurringReminders({
  required List<RecurringRule> rules,
  required DateTime now,
  required String Function(RecurringRule rule, DateTime date) format,
  int horizonDays = 62,
}) {
  final reminders = <Reminder>[];
  final horizon = now.add(Duration(days: horizonDays));

  for (final rule in rules) {
    // Ближайшие вхождения: текущий месяц и следующие, пока в горизонте.
    var year = now.year;
    var month = now.month;
    for (var i = 0; i <= horizonDays ~/ 28 + 1; i++) {
      final occurrence = rule.occurrenceIn(year, month);
      final fireAt = DateTime(occurrence.year, occurrence.month,
              occurrence.day, reminderHour)
          .subtract(const Duration(days: 1));

      if (fireAt.isAfter(now) && fireAt.isBefore(horizon)) {
        reminders.add(Reminder(
          id: reminderIdFor(rule.id, occurrence),
          title: format(rule, occurrence),
          body: rule.note,
          when: fireAt,
        ));
      }

      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
  }

  reminders.sort((a, b) => a.when.compareTo(b.when));
  return reminders;
}

/// Детерминированный id напоминания: правило плюс месяц вхождения.
/// Плагин хранит уведомления по числовому id, поэтому повторное
/// планирование того же платежа перезаписывает прежнее напоминание,
/// а не плодит дубли.
int reminderIdFor(String ruleId, DateTime occurrence) {
  var hash = 0x811c9dc5;
  for (final code in '$ruleId-${occurrence.year}-${occurrence.month}'.codeUnits) {
    hash ^= code;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
}
