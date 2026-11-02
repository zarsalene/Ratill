// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rattil';

  @override
  String get homeStart => 'Start with a short surah';

  @override
  String get homeAll => 'All surahs';

  @override
  String ayahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ayahs',
      one: '1 ayah',
    );
    return '$_temp0';
  }

  @override
  String get modeStrict => 'Strict';

  @override
  String get modeGentle => 'Gentle';

  @override
  String get modeStrictHelp => 'Stops at a mistake';

  @override
  String get modeGentleHelp => 'Marks mistakes and keeps going';

  @override
  String get teacherLoading => 'Preparing the teacher…';

  @override
  String get modelNeeded =>
      'The teacher needs a one-time download. Wi-Fi is best.';

  @override
  String get tapToStart => 'Tap the microphone and recite';

  @override
  String get listening => 'Listening…';

  @override
  String get stopTitle => 'Check this word';

  @override
  String get stopBody => 'Recite again from this word.';

  @override
  String get repeatFromHere => 'Recite from here';

  @override
  String get jumpedBody =>
      'You moved to another place. Go back to the first word you missed.';

  @override
  String get unsure => 'Not sure. Listen to the reciter.';

  @override
  String get tooNoisy => 'Too noisy. Move to a quieter place.';

  @override
  String get perfect => 'Perfect';

  @override
  String doneWithMistakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Done. $count mistakes to review.',
      one: 'Done. 1 mistake to review.',
    );
    return '$_temp0';
  }

  @override
  String get doneNotPerfect => 'Done. Check the orange words.';

  @override
  String get again => 'Start again';

  @override
  String get disclaimer =>
      'Automatic feedback can be wrong. It does not replace a qualified teacher.';

  @override
  String get micTitle => 'Microphone';

  @override
  String get micBody =>
      'Rattil listens to your recitation to check it. The sound stays on your phone. It is never sent anywhere.';

  @override
  String get micContinue => 'Continue';

  @override
  String get micDenied =>
      'Rattil needs the microphone to listen to your recitation. Allow it in the phone settings.';

  @override
  String errorStart(String message) {
    return 'The teacher could not start: $message';
  }

  @override
  String get issueMissingWord => 'Missing word';

  @override
  String get issueWrongLetter => 'Wrong letter';

  @override
  String get issueMissingLetter => 'Missing letter';

  @override
  String get issueExtraLetter => 'Extra letter';

  @override
  String get issueExtraWord => 'Extra word';

  @override
  String get issueHarakat => 'Vowel (harakah)';

  @override
  String get issueLongVowel => 'Long vowel';

  @override
  String get issueShadda => 'Shadda';

  @override
  String get issueTajweed => 'Tajweed hint (beta)';

  @override
  String get legendCorrect => 'Correct';

  @override
  String get legendCheck => 'Check';

  @override
  String get legendMistake => 'Mistake';

  @override
  String get navToday => 'Today';

  @override
  String get navQuran => 'Quran';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionRead => 'Read & listen';

  @override
  String get actionRecite => 'Recite';

  @override
  String get actionMemorize => 'Memorize';

  @override
  String get readHelp => 'Follow the reciter word by word';

  @override
  String get reciteHelp => 'The teacher checks each word';

  @override
  String get memorizeHelp => 'Ayah by ayah, with reviews';

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String ayahN(int n) {
    return 'Ayah $n';
  }

  @override
  String ayahRange(int from, int to) {
    return 'Ayahs $from–$to';
  }

  @override
  String pageN(int n) {
    return 'Page $n';
  }

  @override
  String juzN(int n) {
    return 'Juz $n';
  }

  @override
  String get goalTitle => 'Today\'s goal';

  @override
  String goalProgress(int done, int goal) {
    return '$done of $goal ayahs recited';
  }

  @override
  String get goalDone => 'Goal reached. Well done!';

  @override
  String goalAyahs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ayahs',
      one: '1 ayah',
    );
    return '$_temp0';
  }

  @override
  String streakDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days in a row',
      one: '1 day in a row',
      zero: 'Start your streak today',
    );
    return '$_temp0';
  }

  @override
  String get continueTitle => 'Continue';

  @override
  String get startTitle => 'Start with Al-Fatiha';

  @override
  String get reviewTitle => 'Review';

  @override
  String reviewDue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ayahs to review',
      one: '1 ayah to review',
    );
    return '$_temp0';
  }

  @override
  String get reviewEmpty => 'Nothing to review today.';

  @override
  String reviewDone(int good, int total) {
    return 'Done: $good of $total ayahs remembered well.';
  }

  @override
  String get chooseSurah => 'Choose a surah';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Word, surah, or 2:255';

  @override
  String get searchNoResults => 'No results';

  @override
  String get tabSurahs => 'Surahs';

  @override
  String get tabJuz => 'Juz';

  @override
  String get bookmarks => 'Saved';

  @override
  String get noBookmarks =>
      'Nothing saved yet. Tap an ayah to add a bookmark or a note.';

  @override
  String get pageView => 'Page view';

  @override
  String get listView => 'List view';

  @override
  String get playFromHere => 'Play from here';

  @override
  String get repeatAyah => 'Repeat this ayah';

  @override
  String get reciteFromHere => 'Recite from here';

  @override
  String get memorizeAyah => 'Memorize this ayah';

  @override
  String get bookmarkAdd => 'Bookmark';

  @override
  String get bookmarkRemove => 'Remove bookmark';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get loop => 'Loop the range';

  @override
  String get speed => 'Speed';

  @override
  String get repeatEachTooltip => 'Times each ayah plays';

  @override
  String get reciterName => 'Mishary Rashid Alafasy';

  @override
  String get audioMissing => 'The audio of this surah is not on your phone.';

  @override
  String downloadSize(String mb) {
    return 'Download ($mb MB)';
  }

  @override
  String downloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get downloadFailed =>
      'Download failed. Check the internet and try again.';

  @override
  String get listenWord => 'Listen to the word';

  @override
  String get hint => 'Hint';

  @override
  String get memoryMode => 'From memory';

  @override
  String get hiddenHelp =>
      'Recite from memory. Each word shows when you say it correctly.';

  @override
  String get hiddenWord => 'Hidden word';

  @override
  String get stepListen => '1. Listen';

  @override
  String get stepRead => '2. Read along';

  @override
  String get stepMemory => '3. From memory';

  @override
  String get stepListenHelp =>
      'Listen 3 times. Follow each word with your eyes.';

  @override
  String get stepListenNoAudio => 'Read the ayah aloud 3 times, slowly.';

  @override
  String get listenAgain => 'Listen again';

  @override
  String get next => 'Next';

  @override
  String get nextAyah => 'Next ayah';

  @override
  String get finish => 'Finish';

  @override
  String get tryAgain => 'Try again';

  @override
  String get memorizedOk => 'Memorized!';

  @override
  String get notYet => 'Not yet. Try again: you will get it.';

  @override
  String nextReview(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Next review: in $days days',
      one: 'Next review: tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get allDone => 'Well done!';

  @override
  String get allDoneBody =>
      'These ayahs are now in your reviews. Come back when they are due.';

  @override
  String get badgeEarned => 'New badge!';

  @override
  String get badgeFirstSurah => 'First surah memorized';

  @override
  String get badgeJuzAmma => 'Juz Amma memorized';

  @override
  String get badgeStreak7 => '7 days in a row';

  @override
  String get badgeStreak30 => '30 days in a row';

  @override
  String get badgeFirstReview => 'First review';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get ok => 'OK';

  @override
  String get statStreak => 'Days in a row';

  @override
  String get statBest => 'Best streak';

  @override
  String get statMemorized => 'Ayahs memorized';

  @override
  String get weekTitle => 'Ayahs recited, last 7 days';

  @override
  String get masteryTitle => 'Your Quran map';

  @override
  String get masteryNone => 'Not started';

  @override
  String get masteryStarted => 'Started';

  @override
  String get masteryMemorized => 'Memorized';

  @override
  String get masteryStrong => 'Strong';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsFont => 'Quran text size';

  @override
  String get settingsTeacher => 'Teacher';

  @override
  String get settingsGoal => 'Daily goal';

  @override
  String get settingsAudio => 'Recitation audio';

  @override
  String audioOnPhone(String mb) {
    return 'Downloaded on this phone: $mb MB';
  }

  @override
  String downloadAll(String mb) {
    return 'Download all surahs ($mb MB)';
  }

  @override
  String downloadingAll(int surah) {
    return 'Downloading surah $surah…';
  }

  @override
  String get downloadAllHelp =>
      'Use Wi-Fi. After this, all audio works offline.';

  @override
  String get deleteDownloads => 'Delete downloaded audio';

  @override
  String get confirmDelete =>
      'Delete the downloaded audio of this reciter? Audio included in the app stays.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get settingsAbout => 'About';

  @override
  String get privacy =>
      'No ads. No account. Your voice never leaves your phone.';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesBody =>
      'Quran text: Tanzil.net (Uthmani, verbatim). Recitation: Al-Husary (Muallim) and Mishary Alafasy, via quran.com. Speech model: Quran-Lab (free use only). Fonts: Amiri Quran, Amiri, IBM Plex Sans Arabic. Adhan: CC0 recording from Wikimedia Commons (File:Adhan.ogg, user Aishatu98). Prayer times: adhan_dart (MIT). Translations, unchanged: Saheeh International (English) and Muhammad Hamidullah (French), from Tanzil.net.';

  @override
  String get licenses => 'Licenses';

  @override
  String get onb1Title => 'Learn the Quran with a teacher on your phone';

  @override
  String get onb1Body =>
      'Read, listen, recite, and memorize. It all works without internet.';

  @override
  String get onb2Title => 'The teacher listens to you';

  @override
  String get onb2Body =>
      'Recite aloud. Each word gets a color. At a mistake, the teacher stops, plays the correct word, and you try again.';

  @override
  String get onb3Title => 'A small goal every day';

  @override
  String get onb3Body =>
      'How many ayahs do you want to recite each day? You can change this later.';

  @override
  String get start => 'Start';

  @override
  String get wholeSurah => 'Whole surah';

  @override
  String get greeting => 'Assalamu alaykum';

  @override
  String get ayahOfDay => 'Ayah of the day';

  @override
  String get seeAll => 'See all';

  @override
  String get startSubtitle => '7 short ayahs. The teacher listens and helps.';

  @override
  String get more => 'More';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get reciterHusary => 'Mahmoud Khalil Al-Husary (teaching)';

  @override
  String get reciterHusaryHelp =>
      'Slow and exact. A pause after each ayah to repeat. Best to learn.';

  @override
  String get reciterAlafasyHelp => 'Flowing recitation. Downloads per surah.';

  @override
  String get tapWordHint =>
      'Tap a word to hear it. Tap the ayah number for more.';

  @override
  String get reciterHusaryShort => 'Al-Husary (teaching)';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get prayerTabTimes => 'Times';

  @override
  String get prayerTabQibla => 'Qibla';

  @override
  String get prayerTabTasbih => 'Tasbih';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String prayerNext(String name) {
    return 'Next: $name';
  }

  @override
  String prayerIn(String time) {
    return 'in $time';
  }

  @override
  String get placeNeeded =>
      'To show prayer times, Rattil needs your approximate place once. It stays on your phone and is never sent anywhere.';

  @override
  String get placeFind => 'Use my location';

  @override
  String get placeUpdate => 'Update my location';

  @override
  String placeSaved(String lat, String lon) {
    return 'Saved place: $lat, $lon';
  }

  @override
  String get placeServiceOff =>
      'Location is turned off on this phone. Turn it on and try again.';

  @override
  String get placeDenied => 'Location was not allowed. Try again and allow it.';

  @override
  String get placeDeniedForever =>
      'Location is blocked. Allow it for Rattil in the phone settings.';

  @override
  String get placeFailed =>
      'Could not find your place. Check that location is on and try again.';

  @override
  String get methodLabel => 'Calculation method';

  @override
  String get methodMuslimWorldLeague => 'Muslim World League';

  @override
  String get methodTunisia => 'Tunisia (Ministry of Religious Affairs)';

  @override
  String get methodAlgerian => 'Algeria';

  @override
  String get methodMorocco => 'Morocco';

  @override
  String get methodEgyptian => 'Egypt (General Authority of Survey)';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, Makkah';

  @override
  String get methodKarachi => 'Karachi (University of Islamic Sciences)';

  @override
  String get methodDubai => 'United Arab Emirates';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodTurkiye => 'Türkiye (Diyanet, approximation)';

  @override
  String get methodNorthAmerica => 'North America (ISNA)';

  @override
  String get methodFrance => 'France (UOIF)';

  @override
  String get methodIndonesian => 'Indonesia (Kemenag)';

  @override
  String get methodSingapore => 'Singapore and Malaysia';

  @override
  String get qiblaNeedsPlace => 'Save your place on the Times tab first.';

  @override
  String get qiblaNoSensor =>
      'This phone has no compass sensor, so the Qibla arrow cannot work. The bearing below still helps with a compass.';

  @override
  String get qiblaCalibrate =>
      'The compass needs calibration. Move the phone in a figure 8 and keep it away from metal and magnets.';

  @override
  String qiblaBearing(String deg) {
    return 'Qibla: $deg° from north';
  }

  @override
  String get qiblaFacing => 'You face the Qibla';

  @override
  String get qiblaHold => 'Hold the phone flat.';

  @override
  String get tasbihSubhan => 'SubhanAllah';

  @override
  String get tasbihHamd => 'Alhamdulillah';

  @override
  String get tasbihAkbar => 'Allahu Akbar';

  @override
  String tasbihCount(String count, String goal) {
    return '$count of $goal';
  }

  @override
  String get tasbihTapHint => 'Tap to count';

  @override
  String get tasbihGoalDone => 'Goal reached';

  @override
  String get tasbihAllDone => 'All three goals are done today';

  @override
  String get tasbihReset => 'Reset';

  @override
  String get notifyTitle => 'Notifications';

  @override
  String get notifyAdhan => 'Adhan at prayer time';

  @override
  String get notifyAdhanHelp =>
      'Plays the Adhan, also when the app is closed. Needs your place.';

  @override
  String get notifyRecitation => 'Daily recitation reminder';

  @override
  String get notifyTasbih => 'Tasbih goal reminder';

  @override
  String notifyAt(String time) {
    return 'At $time';
  }

  @override
  String get notifyWhyTitle => 'Allow notifications?';

  @override
  String get notifyWhyBody =>
      'Rattil needs to show notifications to remind you. Nothing is sent from your phone.';

  @override
  String get notifyDenied =>
      'Notifications are blocked. Allow them in the phone settings.';

  @override
  String get notifyExactTitle => 'Exact time';

  @override
  String get notifyExactBody =>
      'For the Adhan to ring at the exact minute, allow alarms on the next screen. Without it, it can be a few minutes late.';

  @override
  String get notifyContinue => 'Continue';

  @override
  String get notifyNotNow => 'Not now';

  @override
  String get notifyBattery =>
      'On some phones, battery saving stops reminders. If the Adhan is late, allow Rattil to run in the background in the phone settings. After a restart, reminders come back when you open Rattil.';

  @override
  String get notifyNeedPlace => 'Save your place on the Prayer tab first.';

  @override
  String reminderAdhanBody(String prayer) {
    return 'It is time for $prayer';
  }

  @override
  String get reminderRecitationTitle => 'Time to recite';

  @override
  String get reminderRecitationBody =>
      'A few ayahs today keep your goal on track.';

  @override
  String get reminderTasbihTitle => 'Tasbih';

  @override
  String get reminderTasbihBody => 'Your daily tasbih goal is waiting.';

  @override
  String get channelAdhan => 'Adhan';

  @override
  String get channelReminders => 'Reminders';

  @override
  String get translationTitle => 'Translation';

  @override
  String get translationNone => 'No translation';

  @override
  String get translationEn => 'English: Saheeh International';

  @override
  String get translationFr => 'French: Muhammad Hamidullah';

  @override
  String get translationHelp =>
      'Shown under each ayah in the Read screen, for the Hafs text. Works without internet. Text from Tanzil.net, unchanged.';

  @override
  String get noteAdd => 'Add a note';

  @override
  String get noteEdit => 'Edit note';

  @override
  String get noteHint => 'Your note. It stays on this phone.';

  @override
  String get noteSave => 'Save';

  @override
  String get noteDelete => 'Delete note';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsHelp =>
      'Soft clicks and short tones. Turn off to mute all of them.';
}
