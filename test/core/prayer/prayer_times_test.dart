import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/prayer/prayer_times.dart';

/// Reference: AlAdhan API (api.aladhan.com/v1/timings), fetched 2026-11-01 for
/// 15 November 2026. It rounds to the minute and uses its own code, so the
/// tolerance is 2 minutes.
void main() {
  final day = DateTime(2026, 11, 15);

  void expectTimes(List<PrayerTime> got, int utcOffsetHours, Map<PrayerName, String> want) {
    expect(got.map((p) => p.name), PrayerName.values);
    for (final p in got) {
      final local = p.time.toUtc().add(Duration(hours: utcOffsetHours));
      final parts = want[p.name]!.split(':').map(int.parse).toList();
      final expected = DateTime.utc(2026, 11, 15, parts[0], parts[1]);
      final diff = local.difference(expected).inSeconds.abs();
      expect(diff, lessThanOrEqualTo(120), reason: '${p.name}: got $local, want ${want[p.name]}');
    }
  }

  test('Tunis, Tunisia method (Fajr 18, Isha 18)', () {
    const tunis = Place(36.81, 10.18);
    expectTimes(prayersOn(tunis, day, PrayerMethod.tunisia), 1, {
      PrayerName.fajr: '05:28',
      PrayerName.dhuhr: '12:04',
      PrayerName.asr: '14:50',
      PrayerName.maghrib: '17:10',
      PrayerName.isha: '18:40',
    });
  });

  test('Makkah, Umm al-Qura method', () {
    const makkah = Place(21.39, 39.86);
    expectTimes(prayersOn(makkah, day, PrayerMethod.ummAlQura), 3, {
      PrayerName.fajr: '05:12',
      PrayerName.dhuhr: '12:05',
      PrayerName.asr: '15:16',
      PrayerName.maghrib: '17:39',
      PrayerName.isha: '19:09',
    });
  });

  test('the default method follows the country, Tunisia has its own', () {
    expect(methodForCountry('TN'), PrayerMethod.tunisia);
    expect(methodForCountry('tn'), PrayerMethod.tunisia);
    expect(methodForCountry('SA'), PrayerMethod.ummAlQura);
    expect(methodForCountry('DZ'), PrayerMethod.algerian);
    expect(methodForCountry('XX'), PrayerMethod.muslimWorldLeague);
    expect(methodForCountry(null), PrayerMethod.muslimWorldLeague);
  });

  test('the next prayer is the first one after now, then tomorrow\'s Fajr', () {
    const tunis = Place(36.81, 10.18);
    final today = prayersOn(tunis, day, PrayerMethod.tunisia);
    final beforeDhuhr = today[1].time.subtract(const Duration(minutes: 5));
    expect(nextPrayer(tunis, beforeDhuhr, PrayerMethod.tunisia).name, PrayerName.dhuhr);
    final beforeFajr = today[0].time.subtract(const Duration(hours: 1));
    expect(nextPrayer(tunis, beforeFajr, PrayerMethod.tunisia).name, PrayerName.fajr);
    final afterIsha = today[4].time.add(const Duration(minutes: 1));
    final next = nextPrayer(tunis, afterIsha, PrayerMethod.tunisia);
    expect(next.name, PrayerName.fajr);
    expect(next.time.isAfter(afterIsha), isTrue);
    expect(next.time.difference(today[0].time).inHours, inInclusiveRange(23, 24));
  });
}
