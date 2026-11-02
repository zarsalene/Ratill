# Rattil enhancement round

Status: final
Last updated: 2026-11-01

## In one sentence
Improve the Rattil (رتّل) free offline Android Quran app: prove the Quran is correct, fix the mic bug, shrink the download, add prayer features (Adhan, Qibla, tasbih, notifications), translation, bookmarks, and more riwayat.

## Problem
- Who has it: the app owner, and later the users of Rattil.
- What hurts:
  - The teacher says "too loud" in a quiet room and stops listening.
  - The 130 MB download takes too long.
  - It is not yet proven that text, font, audio and teacher are all right.
- How they handle it today: APK on GitHub Releases, built with CI. Tests exist for data and align code.

## Users
- Main user: people who read, listen, memorize and recite the Quran on Android (also Tunisia).

## Value
- The one thing it must do very well: show the correct Quran, and give honest feedback when the user recites.

## Scope
### Must-have (this round)
1. Quran correctness, wrong content first:
   - Text matches source (Tanzil and KFGQPC): 114 surahs, 6236 ayahs, every word. Automatic tests in CI (diff vs source, golden ayahs).
   - Display and font: marks, tashkeel, page layout on phone.
   - Audio and word timing.
   - Teacher feedback accuracy.
2. Bug audit: run `flutter analyze` and `flutter test`, review the code, report findings.
3. Mic bug: the "too loud" warning blocks the teacher in a quiet room. Fix with looser limits: higher noise limit, smaller speech gap, warn only after several seconds. No new setting. Warning stays.
   - Start at `NoiseMeter` in `lib/core/asr/pcm.dart` (`maxNoiseDbfs = -38`, `minSnrDb = 12`, marked "starting values for tool/eval to tune") and `noiseSuppress: false` in `lib/core/asr/asr_engine.dart:57`.
4. Smaller download: take the 70 MB speech model (`assets/models/asr.int8.onnx`) and the 22 MB bundled audio out of the APK. The app downloads them after install, with resume and a progress bar. Other APK parts: Quran text 14 MB, fonts 3 MB, Flutter engine.
5. Adhan with location:
   - Ask for GPS once, save the place, compute prayer times on the phone (offline).
   - Prayer times screen with next-prayer countdown.
   - Notification with Adhan sound at prayer time, also when the app is closed.
   - Default calculation method picked by country (Tunisia has its own), user can change it.
   - One Adhan voice with a free license for apps (check license before bundling).
6. Qibla: compass arrow using the phone sensor and the saved place. Works offline.
7. Tasbih: tap counter with small daily count goals (for example 33 SubhanAllah, 33 Alhamdulillah, 34 Allahu Akbar).
8. Notification system (small): Adhan at prayer time, daily recitation reminder, tasbih goal reminder.
9. More riwayat: add Al-Duri an Abi Amr, Al-Susi an Abi Amr, Khalaf an Hamzah, Hisham an Ibn Amir. The owner says Qalun matters most, so check the existing Qalun text first. Each new riwaya is a download on demand (chosen in settings).
10. Translation: French and English from Tanzil translations, with attribution.
11. Bookmarks and notes: per ayah, saved on the phone only.

12. Easy, clear, premium look and feel:
   - Style: dark green and gold, soft cards, clean Arabic type.
   - Navigation: bottom bar with 5 tabs, each with an icon and a word: Read, Listen, Recite, Memorize, Prayer.
   - Animation: smooth screen changes, button press feedback (tasbih tap pulses), green glow on words read right in the teacher, small reward effect (confetti or star) when a goal is done.
   - Sound effects: soft tap click, short tones for right and wrong words in the teacher, chime when a goal is done. One setting mutes all effects.
   - Sound files must be small and free-licensed. Respect system "reduce motion".

13. Basmala rule: the Basmala is a header line before each surah, not an ayah. It has no ayah number, also in Al-Fatiha (there, ayah 1 is "Alhamdulillah"). No Basmala before At-Tawba (surah 9). Applies to the Reader, search, bookmarks, teacher and audio. Today `Riwaya.fatihaBasmalaIsAyah` is true for Hafs and Shuba in `lib/core/quran/riwaya.dart`.
14. Voice must never cut an ayah: bug seen at the end of an ayah, where the last word is clipped. Find the cause (ayah end time from the word timings in `lib/core/audio`), fix it, and add a test that every ayah end time covers the full recitation. The voice plays the Basmala first at the start of each surah (not At-Tawba).

15. Security and vulnerability fixes: follow `ideas/security-fixes.md` (S1 to S8 and the rules for the new features). High items first: private release signing key, SHA-256 check for every downloaded file.

### Nice-to-have (later)
- Streak warning notification
- Memorize tools (better review plan)
- Better teacher (tajweed hints, more reciters, teacher for non-Hafs riwayat)

### Out of scope
- Tafsir
- Better search
- iPhone build
- Google Play release
- Map view for Qibla (needs internet)
- Timed and streak tasbih challenges (only daily count goals)

## Constraints
- Time: a few days (the list is now large, so see Risks).
- Tech / platform: Flutter, Android, no ads, no account.
- Release: APK on GitHub plus the download website.

## Success
- Text tests all green: 114 surahs, 6236 ayahs, every word matches source, CI passes.
- No false "too loud" warning in a normal quiet room on the owner's phone.
- Smaller APK that downloads faster (target size not set yet).
- Adhan plays at the right time, Qibla points the right way, tasbih counts, with the app closed or offline after first setup.
- Translation, bookmarks and notes work in airplane mode.
- A new user finds Read, Listen, Recite, Memorize and Prayer from the bottom bar without help.
- Sound effects can be muted with one setting, and animation respects "reduce motion".
- `flutter analyze` and `flutter test` have zero errors.

## Decided against
- Remove the mic warning: the owner chose looser limits instead.
- Sensitivity slider: not chosen.
- Keep one big APK: the owner chose a small APK with later downloads.
- Riwayat inside the APK: the owner chose download on demand.

## Risks
- The list is large for a few days. Suggested order: correctness, mic bug, smaller APK, then features.
- The README promise "the network is used only to download recitation audio" must change: the speech model and riwayat now also download.
- The teacher then needs internet once after install, before first use.
- The Adhan notification must survive battery saving on some phones (exact alarms permission on Android 12+).
- Compass accuracy changes with the phone sensor.
- Adhan audio license, and French and English translation licenses, are not checked yet.

- Look and sound add work on every screen: do it after correctness and the mic fix.
- The bottom bar now needs a "Prayer" tab (Adhan, Qibla, tasbih). Today's shell is in `lib/features/shell.dart`.

- The Basmala rule differs from the standard Hafs print and the Tanzil data, where the Basmala is ayah 1 of Al-Fatiha. Al-Fatiha ayah numbers and the 6236 total change in the app. The text tests must then allow this one known difference, and the owner must check Al-Fatiha numbering on screen. Owner chose this on 2026-11-01.

## Open questions
- How to number Al-Fatiha ayahs 1 to 7 when the Basmala has no number (the last ayah may split in two)? Needs the owner's decision or a scholar check.
- Target APK size and where to host the extra files (GitHub is slow in Tunisia).
- Exact limit values for the mic check (tune on the owner's phone).
- Which French and English translators from Tanzil.
- Audio source for the new riwayat (mp3quran has IDs for them?).
- Display, font and audio timing have no automatic proof yet. The owner chose automatic tests only, no manual sign-off.
