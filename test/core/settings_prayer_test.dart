import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/prayer/prayer_times.dart';
import 'package:rattil/core/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Settings s;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    s = Settings(await SharedPreferences.getInstance());
  });

  test('no place until the reader saves one; it round-trips and can be removed', () {
    expect(s.place, isNull);
    s.place = Place.rounded(36.8065, 10.1815);
    expect(s.place!.lat, 36.81);
    expect(s.place!.lon, 10.18);
    s.place = null;
    expect(s.place, isNull);
  });

  test('the chosen method is kept', () {
    s.prayerMethod = PrayerMethod.tunisia;
    expect(s.prayerMethod, PrayerMethod.tunisia);
    s.prayerMethod = PrayerMethod.egyptian;
    expect(s.prayerMethod, PrayerMethod.egyptian);
  });

  test('notifications are off by default, and each one can be turned on and off', () {
    expect(s.adhanOn, isFalse);
    expect(s.recitationReminder, isNull);
    expect(s.tasbihReminder, isNull);
    s.adhanOn = true;
    s.recitationReminder = 1200;
    s.tasbihReminder = 1260;
    expect((s.adhanOn, s.recitationReminder, s.tasbihReminder), (true, 1200, 1260));
    s.recitationReminder = null;
    expect(s.recitationReminder, isNull);
  });
}
