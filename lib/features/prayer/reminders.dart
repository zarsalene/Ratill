import '../../app_scope.dart';
import '../../core/notify/reminder_plan.dart';
import '../../core/prayer/prayer_times.dart';
import '../../l10n/app_localizations.dart';
import 'labels.dart';

/// Replaces the scheduled Adhan and reminders with what the settings say now.
/// Call it after the place, the method, a switch or the tasbih goal changes.
/// Never throws: a failed schedule must not break the screen. True when done.
Future<bool> refreshReminders(AppServices s, AppLocalizations t) async {
  final st = s.settings;
  final place = st.place;
  final plan = planReminders(
    now: DateTime.now(),
    place: place ?? const Place(0, 0),
    method: st.prayerMethod,
    adhan: st.adhanOn && place != null,
    recitationMinute: st.recitationReminder,
    tasbihMinute: st.tasbihReminder,
    tasbihGoalDoneToday: s.tasbih.allGoalsReached,
  );
  try {
    await s.notifications.schedule(
      plan,
      title: (r) => switch (r.kind) {
        ReminderKind.adhan => prayerLabel(t, r.prayer!),
        ReminderKind.recitation => t.reminderRecitationTitle,
        ReminderKind.tasbih => t.reminderTasbihTitle,
      },
      body: (r) => switch (r.kind) {
        ReminderKind.adhan => t.reminderAdhanBody(prayerLabel(t, r.prayer!)),
        ReminderKind.recitation => t.reminderRecitationBody,
        ReminderKind.tasbih => t.reminderTasbihBody,
      },
      adhanChannelName: t.channelAdhan,
      reminderChannelName: t.channelReminders,
    );
    return true;
  } catch (_) {
    return false;
  }
}

/// True when any notification is switched on.
bool anyReminderOn(AppServices s) =>
    s.settings.adhanOn || s.settings.recitationReminder != null || s.settings.tasbihReminder != null;
