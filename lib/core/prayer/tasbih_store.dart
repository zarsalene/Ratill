import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three tasbih of the day, with their daily count goal.
enum Dhikr {
  subhanAllah(33),
  alhamdulillah(33),
  allahuAkbar(34);

  const Dhikr(this.goal);
  final int goal;
}

/// Daily tasbih counts, saved on the phone only. A new calendar day starts at 0.
class TasbihStore extends ChangeNotifier {
  TasbihStore(this._prefs, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  String _key(Dhikr d) {
    final t = _now();
    return 'tasbih.${t.year}-${t.month}-${t.day}.${d.name}';
  }

  int count(Dhikr d) => _prefs.getInt(_key(d)) ?? 0;

  bool goalReached(Dhikr d) => count(d) >= d.goal;

  bool get allGoalsReached => Dhikr.values.every(goalReached);

  bool _pruned = false;

  /// Counts of old days are of no use: remove the ones older than 60 days (once).
  void _prune() {
    if (_pruned) return;
    _pruned = true;
    final t = _now();
    final limit = DateTime(t.year, t.month, t.day - 60);
    for (final k in _prefs.getKeys().toList()) {
      final m = RegExp(r'^tasbih\.(\d+)-(\d+)-(\d+)\.').firstMatch(k);
      if (m == null) continue;
      final day = DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
      if (day.isBefore(limit)) _prefs.remove(k);
    }
  }

  void tap(Dhikr d) {
    _prune();
    _prefs.setInt(_key(d), count(d) + 1);
    notifyListeners();
  }

  void reset(Dhikr d) {
    _prefs.remove(_key(d));
    notifyListeners();
  }
}
