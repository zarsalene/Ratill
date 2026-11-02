# Rattil progress

Read this first in every session. Update after every step.
Flutter: `C:\Users\zarsa\dev\flutter\bin` (not on PATH; add it in the shell).
`tool/data/check_sums.py` does not exist. Checksums live in `data/CHECKSUMS`, `data/CHECKSUMS_QIRAAT`, `tool/fetch_models.py`.

## Baseline (2026-11-01, HEAD 9357858, clean tree)

- `flutter analyze`: 35 issues, 31 errors. UI still uses the old `Reciter` enum / nullable `AudioCatalog` API.
- `flutter test`: `+70 -4`. 4 files fail to compile: `aligner_test`, `audio_meta_test`, `screens_test`, `app_test`.

| Step | Topic | Status | Date | analyze (last line) | test (last line) |
|---|---|---|---|---|---|
| 0 | Fix red baseline (compile errors) | done | 2026-11-01 | `5 issues found.` (0 errors, 5 infos) | `00:41 +100 ~3: All tests passed!` |
| 1 | Quran text tests | done (Hafs vs KFGQPC not verified, see notes) | 2026-11-01 | `5 issues found.` (0 errors, 5 infos) | `00:41 +100 ~3: All tests passed!` |
| 2 | Bug audit | done: report below, owner decides the non-content fixes | 2026-11-01 | | |
| 3 | Basmala rule | SKIPPED by owner for now (Al-Fatiha numbering undecided) | | | |
| 4 | Voice never cuts an ayah | done (needs ear test on phone) | 2026-11-01 | | |
| 5 | Mic "too loud" bug | done (limits need phone test) | 2026-11-01 | | |
| 6 | Smaller APK, model download | code done. APK size NOT measured (no Android SDK on this PC) | 2026-11-01 | `5 issues found.` (0 errors) | `+177 ~3: All tests passed!` |
| 7 | Prayer tab | done: 5 tabs Today, Quran, Progress, Prayer, Settings (owner choice) | 2026-11-01 | same | same |
| 8 | Adhan with location | done in code; not tried on a phone | 2026-11-01 | same | same |
| 9 | Qibla | done in code; not tried on a phone | 2026-11-01 | same | same |
| 10 | Tasbih | done | 2026-11-01 | same | same |
| 11 | Notifications | done in code; not tried on a phone | 2026-11-01 | same | same |
| 12 | More riwayat | BLOCKED: no verified source (see notes). Not coded. | 2026-11-01 | | |
| 13 | Translation | done (Saheeh International en, Hamidullah fr; owner choice) | 2026-11-01 | same | same |
| 14 | Bookmarks and notes | done (bookmarks existed; notes added) | 2026-11-01 | same | same |
| 15 | Look and feel | done in part (see notes) | 2026-11-01 | same | same |
| 16 | Security fixes | S2, S3, S4, S5, S6, S7, S8 done. S1 SKIPPED by owner. | 2026-11-01 | same | same |

## Notes

- Step 0: UI migrated to nullable `AppServices.audio` and class `Reciter` (7 files + 1 test). Download-all button hides for reciters with unknown sizes (online reciters). No UI picks online reciters or a riwaya yet.
- Step 1: added `test/data/qiraat_data_test.dart` (18 tests, 5 riwayat). Mutation check done: a cut Qalun 2:255 fails. CI runs `tool/data/build_qiraat.py` before the tests (build.yml). `build_qiraat.py` rebuild gives no diff in `assets/qiraat`. Tanzil sums OK with `sha256sum -c data/CHECKSUMS`.
- Step 1 not verified: Hafs text vs KFGQPC (QUL files `script-312.sqlite` are a manual download, not in the repo). Hafs vs Tanzil is covered by the old test.
- For step 12: `assets/qiraat/` and `assets/fonts/qiraat/` are not in `pubspec.yaml`, and nothing calls `Riwaya.font` or `setRiwaya`. Non-Hafs riwayat are data only today. Al-Duri and al-Susi are not built (6217 ayahs, count unconfirmed). Khalaf and Hisham: no source found yet.
- Open question to ask: Al-Fatiha numbering (step 3).

## Step 2 audit (report from a read-only subagent, 15 items; I checked #1 and the data claims of #2)

Content:
1. Tanzil source itself has `bismillah` with a stray shadda ("بِّسْمِ") for surahs 95 and 97 (110 other surahs use "بِسْمِ"). Source: `data/raw/tanzil/quran-uthmani.xml`, `<sura index="95">` and `<sura index="97">`, attribute `bismillah`. Rule 1: not edited. Owner decides (ask Tanzil, or show the Basmala from one source for all surahs).
2. Audio timings: 8 Husary ayahs and 20-22 Alafasy ayahs have a last word that ends after the ayah `to`. Fixed in the player (step 4) by using `AyahTiming.end`. The data itself is unchanged.
3. Latent (no UI switches riwaya): bookmarks and cards have no riwaya key; page view, search and teacher always use Hafs text; `Riwaya.font` never used. Step 12 must fix.

Crash/leak (not fixed, ask owner):
4. `TeacherController.init()` can finish after `dispose()` (engine and isolate leak, notify after dispose). Same in memorize and review screens.
5. `asr_worker.dart` `dispose()` kills the isolate before `_Stop` is handled (native model may leak). Unverified.
6. `setState` after `await c.setRange` without `mounted` (memorize, review).
7. `progress.setLast` calls `notifyListeners` inside `dispose()` (debug assertion). Unverified.

Other (not fixed, ask owner):
8. `session.dart` `resumeFrom` keeps `_confirmed`: same wrong letter is not stopped twice in strict mode.
9. `_seen` confirmation never decays ("in a row" is not enforced).
10. Mode picker in `stopped`/`finished` phase replaces the session (results lost).
11. Ayahs with `jumped`/`skipped` words count as recited (daily goal and streak).
12. `settings_screen.dart` listens to the old catalog after a reciter change (I moved `?s.audio` inside nothing: the merge is still outside the builder). Fix needed.
13. Day maths with `Duration(days:)` (Tunisia has no DST: low).
14. `results` copies the map on every call (performance).
15. Download: a full-size `.part` gives HTTP 416 and the surah fails forever (audio_catalog.dart download). The new `downloadVerified` handles this case for the model only.

## Notes: steps 4, 5, 6

- Step 4 root cause: the player stopped at ayah `to`; for some ayahs the word times run past it. New `AyahTiming.end = max(to, last word end)`, used by the player and by `wordSpan`. The player no longer seeks back to a next ayah that starts earlier (overlapping data). Test: every ayah of both built-in reciters has `end >= every word end`. Basmala: in both timing files ayah 1 starts at 0 in every surah, so the leading Basmala already plays (surah 9 has none). Not verified by ear. No tail pad added (no evidence): if the end still sounds cut on a phone, add ~150 ms.
- Step 5: `NoiseMeter` limits now `maxNoiseDbfs -30` (was -38), `minSnrDb 8` (was 12), and the warning needs 3 s in a row (`minNoisyMs`). 6 new tests (quiet room, auto-gain floor, burst, sustained noise, recovery). I could not reproduce the false warning without the phone: the real cause (auto gain raising the floor, or speech frames leaking into the noise estimate) is a guess. The final values need a test on the owner's phone.
- Step 6: speech model (72,705,392 bytes) no longer in `pubspec.yaml`. It downloads from the pinned Hugging Face commit (302 to CDN, Range works: checked with curl), through `downloadVerified` (resume, SHA-256 on the `.part` file before rename, delete on mismatch). Teacher shows "needs download" with progress and retry. `assets/audio/husary_muallim` removed from git (`git rm`, not committed) and from `pubspec.yaml`: Al-Fatiha and Juz 30 now download like other surahs, with a length check only (third-party source, no pinned sum possible). `tool/fetch_audio.py` and `data/AUDIO_CHECKSUMS.husary_muallim` are now obsolete (left in place).
- Not verified: the real download on a phone; the model download over redirect with resume.

## Steps 7 to 16 (2026-11-01)

- Checks at the end: `flutter analyze` 5 issues (0 errors, 5 infos from older code: 3 doc-comment angle brackets, 1 initializing formal, 1 more), `flutter test` `+177 ~3: All tests passed!`, website `node --test` 7 pass, `sha256sum -c data/CHECKSUMS` all OK, `build_qiraat.py` rebuild ok.
- Owner decisions this session: skip step 3 for now; skip S1; bottom bar = add Prayer only; English translation = Saheeh International.
- Step 7 to 11: new packages adhan_dart (MIT), geolocator (MIT), flutter_local_notifications (BSD-3), timezone (BSD-2), flutter_timezone (Apache-2), sensors_plus (BSD-3), crypto. All have a release in the last 6 months. `flutter pub outdated` lists newer majors only for some transitive packages. No vulnerability scanner (osv-scanner) installed: NOT run.
  - Times checked against the AlAdhan API (not a printed table) for Tunis (Tunisia method, Fajr 18 / Isha 18) and Makkah (Umm al-Qura), 2 minutes tolerance. Qibla checked against AlAdhan for Tunis (112.67) and London (118.99).
  - Permissions: ACCESS_COARSE_LOCATION, SCHEDULE_EXACT_ALARM, POST_NOTIFICATIONS (from the plugin), plus INTERNET. No boot receiver and no RECEIVE_BOOT_COMPLETED (rule 2 of security-fixes.md): after a restart the Adhan and reminders return only when the app is opened. Ask owner if a boot receiver is wanted.
  - Adhan sound: CC0 `File:Adhan.ogg` from Wikimedia Commons (user Aishatu98, 338,741 bytes, SHA-256 faeb03e4338554fb8b54dba98ed4949648615b58e991bbd560a89f4837dde413, 42 s mono). The CC0 mark is the uploader's claim. Not listened to.
  - Default method comes from the phone's region. Only countries with a preset in adhan_dart are mapped.
- Step 12 blocked: Khalaf an Hamzah and Hisham an Ibn Amir have NO text source in the pinned KFGQPC mirror (folders: hafs, hafs-smart, warsh, shouba, qaloon, doori, soosi, bazzi, qumbul). Al-Duri (doori) and Al-Susi (soosi) have data, but the ayah count (6217) is not confirmed (build_qiraat.py note) and the KFGQPC license terms are not verified (the mirror has no license; the Complex page gave no terms). mp3quran riwaya ids exist: Aldori 13, Assosi 7, Khalaf 3, Hesham 19. Also the app has no UI to switch riwaya yet. Needs from owner: license terms, the confirmed Al-Duri/Al-Susi ayah count, and a text source for Khalaf and Hisham.
- Step 13: files pinned in `data/CHECKSUMS` (data/raw/tanzil/trans). Shown only for Hafs text, in the Reader (not in the page view). Redistribution terms: NOT verified. Default follows the app language (fr, en; none for Arabic).
- Step 14: notes per ayah (stored with progress, on the phone). `allowBackup=false` keeps them out of backups.
- Step 15 done: sound effects (4 files made by `tool/make_sounds.py`, one switch in Settings), reward star burst, tasbih press pulse, green glow on words read right, calm screen transitions, reduce-motion respected (transitions, pulse rings, glow fade, reward, tasbih pulse). NOT done: separate Read / Listen / Recite / Memorize tabs (owner chose Prayer-only); Semantics labels only where already present plus the new Tasbih and Qibla widgets (no TalkBack test).
- Step 16: S2 `downloadVerified` (used for the model; third-party audio has no pin). S3 https-only and host `mp3quran.net`, `usesCleartextTraffic=false`. S4 integer id, and stored ids checked. S5 `allowBackup=false`. S6 actions pinned to SHAs, build job read-only, publish job write-only on main. S7 node_modules untracked (`git rm --cached`, not committed) and site-only deploy plus a CSP meta (privacy.html keeps `style-src 'unsafe-inline'` for its inline style). S8 400 on a bad URL, with a test. Website privacy text updated (location, notes, model download).
- Not verified (any step): everything that needs a phone (Adhan alarm at the minute, location prompt, compass, mic limits, audio clipping, the model download over a real network, sound effects, notification permission flow). Not run: ponytail-audit, a real release build (no Android SDK).
- Code review (code-review, medium) found 9 points; fixed: goal reward baseline, controller work after dispose, sound cache, high latitudes, stale GPS fix, notification init race, tasbih old keys, bad note entry, stored reciter id. Not changed: `Reciter.apiId` drops all rows if the API ever sends string ids (by design of S4).
