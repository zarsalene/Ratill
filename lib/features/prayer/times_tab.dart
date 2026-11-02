import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/prayer/place_finder.dart';
import '../../core/prayer/prayer_times.dart';
import '../../l10n/app_localizations.dart';
import 'labels.dart';
import 'reminders.dart';

/// Prayer times for the saved place, the next prayer with a countdown, and the
/// calculation method. The place is asked once, at city level.
class TimesTab extends StatefulWidget {
  const TimesTab({super.key});

  @override
  State<TimesTab> createState() => _TimesTabState();
}

class _TimesTabState extends State<TimesTab> {
  Timer? _tick;
  bool _busy = false;
  PlaceError? _error;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      // Only redraw while the tab is on screen (an IndexedStack turns tickers off for hidden tabs).
      if (mounted && TickerMode.valuesOf(context).enabled) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _find() async {
    final s = AppScope.of(context);
    final t = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await findPlace();
    if (r.place != null) {
      s.settings.place = r.place;
      await refreshReminders(s, t);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = r.error;
    });
  }

  String _clock(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, sec = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '$h:${two(m)}:${two(sec)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final s = AppScope.of(context);
    final st = s.settings;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: st,
      builder: (context, _) {
        final place = st.place;
        final error = _error;
        final errorText = switch (error) {
          PlaceError.serviceOff => t.placeServiceOff,
          PlaceError.denied => t.placeDenied,
          PlaceError.deniedForever => t.placeDeniedForever,
          PlaceError.failed => t.placeFailed,
          null => null,
        };
        final findButton = _busy
            ? const Center(child: CircularProgressIndicator())
            : FilledButton.icon(
                onPressed: _find,
                icon: const Icon(Icons.my_location),
                label: Text(place == null ? t.placeFind : t.placeUpdate),
              );
        if (place == null) {
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text(t.placeNeeded, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            findButton,
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(errorText, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ]);
        }
        final now = DateTime.now();
        final method = st.prayerMethod;
        final next = nextPrayer(place, now, method);
        final today = prayersOn(place, now, method);
        final loc = MaterialLocalizations.of(context);
        String clock(DateTime d) => loc.formatTimeOfDay(TimeOfDay.fromDateTime(d.toLocal()));
        return ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text(t.prayerNext(prayerLabel(t, next.name)), style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(clock(next.time), style: theme.textTheme.displaySmall),
                const SizedBox(height: 4),
                Text(t.prayerIn(_clock(next.time.difference(now))), style: theme.textTheme.titleMedium),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          for (final p in today)
            ListTile(
              selected: p.name == next.name && p.time == next.time,
              leading: const Icon(Icons.access_time),
              title: Text(prayerLabel(t, p.name)),
              trailing: Text(clock(p.time), style: theme.textTheme.titleMedium),
            ),
          const SizedBox(height: 8),
          Text(t.methodLabel, style: theme.textTheme.titleSmall),
          DropdownButton<PrayerMethod>(
            isExpanded: true,
            value: method,
            items: [for (final m in PrayerMethod.values) DropdownMenuItem(value: m, child: Text(methodLabel(t, m)))],
            onChanged: (m) async {
              if (m == null) return;
              st.prayerMethod = m;
              await refreshReminders(s, t);
            },
          ),
          const SizedBox(height: 12),
          Text(t.placeSaved(place.lat.toStringAsFixed(2), place.lon.toStringAsFixed(2)), style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          findButton,
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(errorText, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ]);
      },
    );
  }
}
