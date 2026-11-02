import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/notify/reminder_plan.dart';
import 'package:rattil/core/prayer/prayer_times.dart';

void main() {
  const tunis = Place(36.81, 10.18);
  final noon = DateTime(2026, 11, 15, 12, 30); // after Fajr, before Dhuhr+ (local, Tunis has no DST)

  List<Reminder> plan({bool adhan = false, int? recitation, int? tasbih, bool tasbihDone = false, int days = 3}) => planReminders(
        now: noon,
        place: tunis,
        method: PrayerMethod.tunisia,
        adhan: adhan,
        recitationMinute: recitation,
        tasbihMinute: tasbih,
        tasbihGoalDoneToday: tasbihDone,
        days: days,
      );

  test('nothing is on: nothing is planned', () {
    expect(plan(), isEmpty);
  });

  test('adhan: every prayer of the days ahead that is still in the future, in time order', () {
    final p = plan(adhan: true);
    expect(p.every((r) => r.kind == ReminderKind.adhan && r.time.isAfter(noon)), isTrue);
    final times = [for (final r in p) r.time];
    expect(times, [...times]..sort());
    // Today: Asr, Maghrib, Isha (Dhuhr may be before 12:30 local in Tunis). Then 5 per day for 2 more days.
    expect(p.length, inInclusiveRange(13, 14));
    expect(p.where((r) => r.prayer == PrayerName.fajr).length, 2);
  });

  test('the reminders at a fixed minute of the day: only future ones, one per day', () {
    final p = plan(recitation: 20 * 60);
    expect(p.length, 3); // 15, 16, 17 Nov at 20:00
    expect(p.every((r) => r.kind == ReminderKind.recitation && r.time.hour == 20 && r.time.minute == 0), isTrue);
    final late = planReminders(
      now: DateTime(2026, 11, 15, 21),
      place: tunis,
      method: PrayerMethod.tunisia,
      adhan: false,
      recitationMinute: 20 * 60,
      tasbihMinute: null,
      tasbihGoalDoneToday: false,
      days: 3,
    );
    expect(late.first.time.day, 16);
  });

  test('the tasbih reminder skips today when the daily goal is done', () {
    final todo = plan(tasbih: 21 * 60);
    final done = plan(tasbih: 21 * 60, tasbihDone: true);
    expect(todo.length, 3);
    expect(done.length, 2);
    expect(done.first.time.day, 16);
  });

  test('ids are unique', () {
    final p = plan(adhan: true, recitation: 1200, tasbih: 1260, days: 7);
    expect({for (final r in p) r.id}.length, p.length);
  });
}
