import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import 'reminders.dart';

/// One screen to turn each notification on or off. The permission is asked
/// only when a switch is turned on, after a short explanation.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _recitationDefault = 20 * 60;
  static const _tasbihDefault = 21 * 60;

  /// Explains, then asks for the notification permission. True when allowed.
  Future<bool> _allowNotifications(BuildContext context, AppServices s, AppLocalizations t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.notifyWhyTitle),
        content: Text(t.notifyWhyBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.notifyNotNow)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.notifyContinue)),
        ],
      ),
    );
    if (ok != true) return false;
    final granted = await s.notifications.requestPermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.notifyDenied)));
    }
    return granted;
  }

  /// The Adhan needs exact alarms to ring at the minute. Without them it is
  /// scheduled a few minutes loose, so a "no" is fine.
  Future<void> _allowExact(BuildContext context, AppServices s, AppLocalizations t) async {
    if (await s.notifications.canScheduleExact() || !context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.notifyExactTitle),
        content: Text(t.notifyExactBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.notifyNotNow)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.notifyContinue)),
        ],
      ),
    );
    if (ok == true) await s.notifications.requestExactAlarms();
  }

  Future<void> _apply(AppServices s, AppLocalizations t) async {
    if (anyReminderOn(s)) {
      await refreshReminders(s, t);
    } else {
      await s.notifications.cancelAll();
    }
  }

  Future<void> _toggleAdhan(BuildContext context, AppServices s, AppLocalizations t, bool on) async {
    if (!on) {
      s.settings.adhanOn = false;
    } else {
      if (s.settings.place == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.notifyNeedPlace)));
        return;
      }
      if (!await _allowNotifications(context, s, t) || !context.mounted) return;
      await _allowExact(context, s, t);
      s.settings.adhanOn = true;
    }
    await _apply(s, t);
  }

  Future<void> _toggleDaily(BuildContext context, AppServices s, AppLocalizations t, bool on, int? current, int fallback,
      void Function(int?) save) async {
    if (!on) {
      save(null);
    } else {
      if (!await _allowNotifications(context, s, t) || !context.mounted) return;
      save(current ?? fallback);
    }
    await _apply(s, t);
  }

  Future<void> _pickTime(BuildContext context, AppServices s, AppLocalizations t, int minute, void Function(int?) save) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60));
    if (picked == null) return;
    save(picked.hour * 60 + picked.minute);
    await _apply(s, t);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final s = AppScope.of(context);
    final st = s.settings;
    final loc = MaterialLocalizations.of(context);
    String at(int m) => t.notifyAt(loc.formatTimeOfDay(TimeOfDay(hour: m ~/ 60, minute: m % 60)));
    return Scaffold(
      appBar: AppBar(title: Text(t.notifyTitle)),
      body: ListenableBuilder(
        listenable: st,
        builder: (context, _) {
          final rec = st.recitationReminder, tas = st.tasbihReminder;
          return ListView(children: [
            SwitchListTile(
              value: st.adhanOn,
              title: Text(t.notifyAdhan),
              subtitle: Text(t.notifyAdhanHelp),
              onChanged: (v) => _toggleAdhan(context, s, t, v),
            ),
            SwitchListTile(
              value: rec != null,
              title: Text(t.notifyRecitation),
              subtitle: rec == null ? null : Text(at(rec)),
              onChanged: (v) => _toggleDaily(context, s, t, v, rec, _recitationDefault, (m) => st.recitationReminder = m),
            ),
            if (rec != null)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(at(rec)),
                onTap: () => _pickTime(context, s, t, rec, (m) => st.recitationReminder = m),
              ),
            SwitchListTile(
              value: tas != null,
              title: Text(t.notifyTasbih),
              subtitle: tas == null ? null : Text(at(tas)),
              onChanged: (v) => _toggleDaily(context, s, t, v, tas, _tasbihDefault, (m) => st.tasbihReminder = m),
            ),
            if (tas != null)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(at(tas)),
                onTap: () => _pickTime(context, s, t, tas, (m) => st.tasbihReminder = m),
              ),
            Padding(padding: const EdgeInsets.all(16), child: Text(t.notifyBattery, style: Theme.of(context).textTheme.bodySmall)),
          ]);
        },
      ),
    );
  }
}
