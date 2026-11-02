import '../../core/prayer/prayer_times.dart';
import '../../core/prayer/tasbih_store.dart';
import '../../l10n/app_localizations.dart';

String prayerLabel(AppLocalizations t, PrayerName p) => switch (p) {
      PrayerName.fajr => t.prayerFajr,
      PrayerName.dhuhr => t.prayerDhuhr,
      PrayerName.asr => t.prayerAsr,
      PrayerName.maghrib => t.prayerMaghrib,
      PrayerName.isha => t.prayerIsha,
    };

String methodLabel(AppLocalizations t, PrayerMethod m) => switch (m) {
      PrayerMethod.muslimWorldLeague => t.methodMuslimWorldLeague,
      PrayerMethod.tunisia => t.methodTunisia,
      PrayerMethod.algerian => t.methodAlgerian,
      PrayerMethod.morocco => t.methodMorocco,
      PrayerMethod.egyptian => t.methodEgyptian,
      PrayerMethod.ummAlQura => t.methodUmmAlQura,
      PrayerMethod.karachi => t.methodKarachi,
      PrayerMethod.dubai => t.methodDubai,
      PrayerMethod.qatar => t.methodQatar,
      PrayerMethod.kuwait => t.methodKuwait,
      PrayerMethod.turkiye => t.methodTurkiye,
      PrayerMethod.northAmerica => t.methodNorthAmerica,
      PrayerMethod.france => t.methodFrance,
      PrayerMethod.indonesian => t.methodIndonesian,
      PrayerMethod.singapore => t.methodSingapore,
    };

String dhikrLabel(AppLocalizations t, Dhikr d) => switch (d) {
      Dhikr.subhanAllah => t.tasbihSubhan,
      Dhikr.alhamdulillah => t.tasbihHamd,
      Dhikr.allahuAkbar => t.tasbihAkbar,
    };
