import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/reminders.dart';
import 'package:numo/models/recurring.dart';
import 'package:numo/models/transaction.dart';

/// Правила «о чём и когда напомнить» — чистая логика, плагин
/// уведомлений в тестах не участвует (ADR-0015).
void main() {
  RecurringRule rule(String id, {required int day, String note = ''}) =>
      RecurringRule(
        id: id,
        type: TxType.expense,
        amount: 990,
        categoryId: 'entertainment',
        note: note,
        dayOfMonth: day,
        startDate: DateTime(2026, 1, day),
      );

  String title(RecurringRule r, DateTime date) => 'Завтра: ${r.id}';

  test('напоминание приходит накануне в 10 утра', () {
    final reminders = upcomingRecurringReminders(
      rules: [rule('sub', day: 15)],
      now: DateTime(2026, 8, 1),
      format: title,
    );

    expect(reminders.first.when, DateTime(2026, 8, 14, reminderHour));
    expect(reminders.first.title, 'Завтра: sub');
  });

  test('уже прошедшая в этом месяце дата переносится на следующий', () {
    final reminders = upcomingRecurringReminders(
      rules: [rule('sub', day: 5)],
      now: DateTime(2026, 8, 20),
      format: title,
    );

    expect(reminders.first.when, DateTime(2026, 9, 4, reminderHour));
  });

  test('горизонт ограничивает список', () {
    final reminders = upcomingRecurringReminders(
      rules: [rule('sub', day: 15)],
      now: DateTime(2026, 8, 1),
      format: title,
      horizonDays: 20,
    );

    expect(reminders, hasLength(1));
  });

  test('несколько правил идут по возрастанию даты', () {
    final reminders = upcomingRecurringReminders(
      rules: [rule('late', day: 25), rule('early', day: 10)],
      now: DateTime(2026, 8, 1),
      format: title,
    );

    expect(reminders.first.title, 'Завтра: early');
    // Горизонт по умолчанию — два месяца, поэтому дальше идут
    // сентябрьские вхождения тех же правил.
    expect(reminders.take(2).map((r) => r.when).toList(),
        [DateTime(2026, 8, 9, 10), DateTime(2026, 8, 24, 10)]);
    expect(reminders.map((r) => r.when).toList(),
        orderedEquals(List.of(reminders.map((r) => r.when))..sort()));
  });

  test('заметка правила становится текстом уведомления', () {
    final reminders = upcomingRecurringReminders(
      rules: [rule('sub', day: 15, note: 'Подписка на музыку')],
      now: DateTime(2026, 8, 1),
      format: title,
    );

    expect(reminders.first.body, 'Подписка на музыку');
  });

  test('id напоминания детерминирован и различает месяцы', () {
    final august = reminderIdFor('sub', DateTime(2026, 8, 15));
    final september = reminderIdFor('sub', DateTime(2026, 9, 15));

    expect(august, reminderIdFor('sub', DateTime(2026, 8, 15)));
    expect(august, isNot(september));
    expect(august, isNot(reminderIdFor('other', DateTime(2026, 8, 15))));
    // Плагин адресует уведомления 32-битным знаковым числом.
    expect(august, lessThan(1 << 31));
  });
}
