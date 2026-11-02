import '../prayer/prayer_times.dart';

enum ReminderKind { adhan, recitation, tasbih }

/// One notification to schedule. [id] is unique inside a plan.
class Reminder {
  const Reminder(this.id, this.kind, this.time, [this.prayer]);
  final int id;
  final ReminderKind kind;

  /// Local time.
  final DateTime time;
  final PrayerName? prayer;
}

/// What to schedule for the next [days] days (today included), computed on the
/// phone. Only times after [now] are planned. The recitation and tasbih
/// reminders fire at a fixed minute of the day ([recitationMinute],
/// [tasbihMinute]: minutes since midnight, null = off). Today's tasbih
/// reminder is dropped when the daily goal is already done.
List<Reminder> planReminders({
  required DateTime now,
  required Place place,
  required PrayerMethod method,
  required bool adhan,
  required int? recitationMinute,
  required int? tasbihMinute,
  required bool tasbihGoalDoneToday,
  int days = 7,
}) {
  final out = <Reminder>[];
  var id = 1;
  for (var d = 0; d < days; d++) {
    final day = DateTime(now.year, now.month, now.day + d);
    if (adhan) {
      for (final p in prayersOn(place, day, method)) {
        final t = p.time.toLocal();
        if (t.isAfter(now)) out.add(Reminder(id++, ReminderKind.adhan, t, p.name));
      }
    }
    for (final (kind, minute) in [(ReminderKind.recitation, recitationMinute), (ReminderKind.tasbih, tasbihMinute)]) {
      if (minute == null) continue;
      if (kind == ReminderKind.tasbih && d == 0 && tasbihGoalDoneToday) continue;
      final t = DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60);
      if (t.isAfter(now)) out.add(Reminder(id++, kind, t));
    }
  }
  out.sort((a, b) => a.time.compareTo(b.time));
  return out;
}
