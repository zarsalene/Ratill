import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'align/session.dart';
import 'prayer/prayer_times.dart';
import 'quran/riwaya.dart';
import 'quran/translation.dart';

/// User settings, saved on the phone.
class Settings extends ChangeNotifier {
  Settings(this._prefs);
  final SharedPreferences _prefs;

  ThemeMode get themeMode => ThemeMode.values.byName(_prefs.getString('theme') ?? 'system');
  set themeMode(ThemeMode v) => _set('theme', v.name);

  /// null = the phone's language.
  Locale? get locale {
    final c = _prefs.getString('locale');
    return c == null ? null : Locale(c);
  }

  set locale(Locale? v) => v == null ? _remove('locale') : _set('locale', v.languageCode);

  /// Size of the Quran text.
  double get quranFontSize => _prefs.getDouble('quranFont') ?? 28;
  set quranFontSize(double v) => _setDouble('quranFont', v);

  TeacherMode get teacherMode => TeacherMode.values.byName(_prefs.getString('teacherMode') ?? 'strict');
  set teacherMode(TeacherMode v) => _set('teacherMode', v.name);

  /// Ayahs to recite per day.
  int get dailyGoal => _prefs.getInt('dailyGoal') ?? 5;
  set dailyGoal(int v) {
    _prefs.setInt('dailyGoal', v);
    notifyListeners();
  }

  /// The riwaya the user reads and listens to.
  Riwaya get riwaya => Riwaya.values.firstWhere((r) => r.name == _prefs.getString('riwaya'), orElse: () => Riwaya.hafs);
  set riwaya(Riwaya v) => _set('riwaya', v.name);

  /// The chosen reciter id of riwaya [r], or null.
  String? reciterIdFor(Riwaya r) => _prefs.getString('reciter.${r.name}');
  void setReciterFor(Riwaya r, String id) => _set('reciter.${r.name}', id);

  /// The translation shown under each ayah, or null for none. Until the reader
  /// chooses, it follows the app language: French or English, none for Arabic.
  Translation? get translation {
    final saved = _prefs.getString('translation');
    if (saved == 'off') return null;
    final chosen = Translation.values.where((t) => t.name == saved).firstOrNull;
    if (chosen != null || saved != null) return chosen;
    return switch ((locale ?? PlatformDispatcher.instance.locale).languageCode) {
      'fr' => Translation.fr,
      'en' => Translation.en,
      _ => null,
    };
  }

  set translation(Translation? v) => _set('translation', v?.name ?? 'off');

  /// The saved place for prayer times and Qibla (rounded to about 1 km, kept
  /// on the phone only, never sent anywhere), or null.
  Place? get place {
    final lat = _prefs.getDouble('place.lat'), lon = _prefs.getDouble('place.lon');
    return lat == null || lon == null ? null : Place(lat, lon);
  }

  set place(Place? v) {
    if (v == null) {
      _prefs.remove('place.lat');
      _prefs.remove('place.lon');
    } else {
      _prefs.setDouble('place.lat', v.lat);
      _prefs.setDouble('place.lon', v.lon);
    }
    notifyListeners();
  }

  /// The prayer calculation method: the reader's choice, else the one of the
  /// phone's region (Tunisia has its own).
  PrayerMethod get prayerMethod {
    final saved = PrayerMethod.values.where((m) => m.name == _prefs.getString('prayerMethod')).firstOrNull;
    return saved ?? methodForCountry(PlatformDispatcher.instance.locale.countryCode);
  }

  set prayerMethod(PrayerMethod v) => _set('prayerMethod', v.name);

  /// Soft sound effects (taps, right and wrong words, goals). One switch.
  bool get soundEffects => _prefs.getBool('soundEffects') ?? true;
  set soundEffects(bool v) => _setBool('soundEffects', v);

  /// Notifications. Off until the reader turns them on.
  bool get adhanOn => _prefs.getBool('notify.adhan') ?? false;
  set adhanOn(bool v) => _setBool('notify.adhan', v);

  /// Minute of the day (0 to 1439) of the daily reminders, or null when off.
  int? get recitationReminder => _prefs.getInt('notify.recitation');
  set recitationReminder(int? v) => _setInt('notify.recitation', v);

  int? get tasbihReminder => _prefs.getInt('notify.tasbih');
  set tasbihReminder(int? v) => _setInt('notify.tasbih', v);

  /// The learner's first name, for the greeting (kept on the phone only).
  String get userName => _prefs.getString('userName') ?? '';
  set userName(String v) => _set('userName', v.trim());

  bool get onboarded => _prefs.getBool('onboarded') ?? false;
  set onboarded(bool v) {
    _prefs.setBool('onboarded', v);
    notifyListeners();
  }

  /// Show the Madani page view (true) or the surah as one list (false).
  bool get pageView => _prefs.getBool('pageView') ?? false;
  set pageView(bool v) {
    _prefs.setBool('pageView', v);
    notifyListeners();
  }

  void _set(String k, String v) {
    _prefs.setString(k, v);
    notifyListeners();
  }

  void _setBool(String k, bool v) {
    _prefs.setBool(k, v);
    notifyListeners();
  }

  void _setInt(String k, int? v) {
    v == null ? _prefs.remove(k) : _prefs.setInt(k, v);
    notifyListeners();
  }

  void _setDouble(String k, double v) {
    _prefs.setDouble(k, v);
    notifyListeners();
  }

  void _remove(String k) {
    _prefs.remove(k);
    notifyListeners();
  }
}
