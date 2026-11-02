import 'package:adhan_dart/adhan_dart.dart' as adhan;

/// A place on Earth. Coordinates are rounded to 0.01 degree (about 1 km): city
/// level is enough for prayer times and keeps the saved place coarse.
class Place {
  const Place(this.lat, this.lon);
  factory Place.rounded(double lat, double lon) => Place(_round(lat), _round(lon));

  final double lat;
  final double lon;

  static double _round(double v) => (v * 100).round() / 100;
}

enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

class PrayerTime {
  const PrayerTime(this.name, this.time);
  final PrayerName name;

  /// A UTC instant. Use `.toLocal()` to show it.
  final DateTime time;
}

/// Calculation methods of the adhan_dart package.
enum PrayerMethod {
  muslimWorldLeague,
  tunisia,
  algerian,
  morocco,
  egyptian,
  ummAlQura,
  karachi,
  dubai,
  qatar,
  kuwait,
  turkiye,
  northAmerica,
  france,
  indonesian,
  singapore;

  adhan.CalculationParameters get params => switch (this) {
        muslimWorldLeague => adhan.CalculationMethodParameters.muslimWorldLeague(),
        tunisia => adhan.CalculationMethodParameters.tunisia(),
        algerian => adhan.CalculationMethodParameters.algerian(),
        morocco => adhan.CalculationMethodParameters.morocco(),
        egyptian => adhan.CalculationMethodParameters.egyptian(),
        ummAlQura => adhan.CalculationMethodParameters.ummAlQura(),
        karachi => adhan.CalculationMethodParameters.karachi(),
        dubai => adhan.CalculationMethodParameters.dubai(),
        qatar => adhan.CalculationMethodParameters.qatar(),
        kuwait => adhan.CalculationMethodParameters.kuwait(),
        turkiye => adhan.CalculationMethodParameters.turkiye(),
        northAmerica => adhan.CalculationMethodParameters.northAmerica(),
        france => adhan.CalculationMethodParameters.france(),
        indonesian => adhan.CalculationMethodParameters.indonesian(),
        singapore => adhan.CalculationMethodParameters.singapore(),
      };
}

/// The default method for an ISO country code (the phone's region). Only
/// countries that have a method of their own in adhan_dart; the rest use the
/// Muslim World League. The reader can change it.
PrayerMethod methodForCountry(String? code) => switch (code?.toUpperCase()) {
      'TN' => PrayerMethod.tunisia,
      'DZ' => PrayerMethod.algerian,
      'MA' => PrayerMethod.morocco,
      'SA' => PrayerMethod.ummAlQura,
      'EG' => PrayerMethod.egyptian,
      'AE' => PrayerMethod.dubai,
      'QA' => PrayerMethod.qatar,
      'KW' => PrayerMethod.kuwait,
      'PK' => PrayerMethod.karachi,
      'TR' => PrayerMethod.turkiye,
      'FR' => PrayerMethod.france,
      'ID' => PrayerMethod.indonesian,
      'SG' || 'MY' => PrayerMethod.singapore,
      'US' || 'CA' => PrayerMethod.northAmerica,
      _ => PrayerMethod.muslimWorldLeague,
    };

/// The five prayers of the calendar [date] (only its year, month and day count).
List<PrayerTime> prayersOn(Place place, DateTime date, PrayerMethod method) {
  final coordinates = adhan.Coordinates(place.lat, place.lon);
  final t = adhan.PrayerTimes(
    coordinates: coordinates,
    date: DateTime(date.year, date.month, date.day),
    // Far north or south, Fajr and Isha may not exist: cap them.
    calculationParameters: method.params..highLatitudeRule = adhan.HighLatitudeRule.recommended(coordinates),
    precision: false,
  );
  return [
    PrayerTime(PrayerName.fajr, t.fajr),
    PrayerTime(PrayerName.dhuhr, t.dhuhr),
    PrayerTime(PrayerName.asr, t.asr),
    PrayerTime(PrayerName.maghrib, t.maghrib),
    PrayerTime(PrayerName.isha, t.isha),
  ];
}

/// The first prayer after [now]: today's, or tomorrow's Fajr after Isha.
PrayerTime nextPrayer(Place place, DateTime now, PrayerMethod method) {
  for (var d = 0; d < 2; d++) {
    final day = DateTime(now.year, now.month, now.day + d);
    for (final p in prayersOn(place, day, method)) {
      if (p.time.isAfter(now)) return p;
    }
  }
  throw StateError('no prayer in the next two days'); // only if the sun never rises or sets
}

/// The Qibla bearing in degrees clockwise from true north.
double qiblaBearing(Place place) => adhan.Qibla.qibla(adhan.Coordinates(place.lat, place.lon));
