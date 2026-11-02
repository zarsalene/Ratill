# Rattil security and vulnerability fixes

Status: final
Last updated: 2026-11-01

This file is part of `ideas/rattil-enhancement.md`. It comes from a read of the manifest, signing config, download code, CI workflows and website. No scanner was run. Each item has: assumption, problem, smallest fix, and a check that proves it is fixed.

Fix in the order below. High items first.

## High

### S1. Release APKs are signed with a public key
- Where: `android/app/build.gradle.kts` (`signingConfigs.test`, password `rattil-test`) and the tracked file `android/app/test-signing.p12`. The release build type uses this key. The CI job publishes every push to main as a GitHub Release.
- Problem: anyone can read the key and password in the repo. Anyone can build a changed APK with the same signature. Android installs it over the real app without a warning. It could steal the microphone, location and notes.
- Smallest fix: make a new private key. Keep it in GitHub Secrets (keystore as base64, store password, key password, alias). Read it in `build.gradle.kts` from environment variables. Remove `test-signing.p12` from git. Keep a debug-only key for local builds.
- Tradeoff to tell the owner: a new key means old installs cannot update. Users uninstall once and install again. Notes and bookmarks on the phone are lost, so do this before notes exist, or say it clearly in the release text.
- Check: `apksigner verify --print-certs Rattil.apk` shows the new certificate. `git ls-files | grep p12` shows nothing. A build without the secrets fails on release. Never commit the new key.

### S2. Downloaded files have no integrity check
- Where: `lib/core/audio/audio_catalog.dart` (`download`, lines 274 to 322).
- Problem: the only check is file length. For built-in reciters the length comes from the catalog. For mp3quran reciters it comes from the server's own `Content-Length`, so the check always passes. A wrong or changed file is accepted and played. After item 6 of the work list (model download) and item 12 (riwayat download), the same code would fetch the 70 MB speech model, and a native library would load it. A bad model file is a memory-safety risk.
- Smallest fix: pin a SHA-256 for every file the app downloads from a source the owner controls (speech model, VAD, riwayat texts, bundled-list audio). `tool/fetch_models.py` already has pinned sums. Reuse them in the app. Hash the `.part` file after the download and before the rename. On mismatch, delete the file and show a clear error with retry.
- For third-party mp3quran audio, no pinned sum exists. State that clearly, play it only through the platform decoder, and do not load it in native code of the app.
- Check: a unit test downloads a fake file with a wrong hash and expects: file deleted, error shown, no rename. A test with the right hash passes.

## Medium

### S3. Audio URL from the web API is not forced to HTTPS
- Where: `lib/core/audio/reciters.dart` line 92 (`server` used as given) and `audio_catalog.dart` line 240 (`_url`). `_folder` at line 106 changes `http://` to `https://` only to match names, not for the real URL.
- Assumption (not verified): Dart `HttpClient` may allow plain HTTP on Android. The manifest has no `usesCleartextTraffic` or network security config.
- Problem: if the API gives an `http://` server, the download is open to change on the network.
- Smallest fix: when building `Reciter.server`, replace `http://` with `https://`. Reject any other scheme. Allow only known hosts (for example `mp3quran.net` and its subdomains, `everyayah.com`). Add `android:usesCleartextTraffic="false"` to `<application>`.
- Check: a unit test with `http://`, `ftp://`, `file://` and an unknown host. Expected: https for the first, rejected for the others.

### S4. Server data builds a file path
- Where: `reciters.dart` line 89 (`id: 'mp3q_${m['id']}'`), used in `audio_catalog.dart` line 192 (`audio/${reciter.id}`).
- Problem: `m['id']` is a dynamic value from the web API. A value such as `../x` would point outside the app folder. Needs a changed or hostile API, so the chance is low.
- Smallest fix: read it as `m['id'] as int`. Keep the rest. A bad row then throws and the existing handler skips it.
- Check: unit test with id `"../x"` expects an error, and with id `12` expects `mp3q_12`.

### S5. Phone backup copies private data
- Where: `AndroidManifest.xml` has no `android:allowBackup`. The default is true.
- Problem: bookmarks, notes and the saved place (new features) go to the user's cloud backup. The README promises that private data stays on the phone.
- Smallest fix: `android:allowBackup="false"` on `<application>`. If backup is wanted later, use an explicit data-extraction rule file.
- Check: `aapt dump xmltree` on the built APK shows `allowBackup=false`.

### S6. CI uses unpinned actions with write permission
- Where: `.github/workflows/build.yml`. The job has `contents: write`. It uses `actions/checkout@v4`, `subosito/flutter-action@v2` and `softprops/action-gh-release@v2` by tag. A moved tag changes what runs, and the job can publish releases.
- Smallest fix: pin the third-party actions to a full commit SHA with the tag in a comment. Split the job: the build step has read permission only. Only the publish step has `contents: write`, and it runs only on main. Keep the signing secrets only in the publish job.
- Check: `grep -n "uses:" .github/workflows/*.yml` shows a 40-character SHA for each third-party action. A pull request run has no write token and no secrets.

## Low

### S7. Website deploys the whole folder
- Where: `.github/workflows/deploy-website.yml` uploads all of `prototype-pwa`. Git tracks 182 files under `prototype-pwa/node_modules` (the test tool Playwright), plus `test/` and `server.js`.
- Problem: test tools and server code are public on GitHub Pages. The repo is large for no reason. The page has no Content-Security-Policy. `app.js` and `privacy.js` set `innerHTML` from own fixed text, not from user input, so there is no hole today. A future change that puts user text there would make one.
- Smallest fix: add `prototype-pwa/node_modules/` to `.gitignore` and run `git rm -r --cached prototype-pwa/node_modules`. Deploy only the site files (copy them into a `site` folder in the workflow, or move the dev files out). Add a `<meta http-equiv="Content-Security-Policy">` that allows only own files. Keep `innerHTML` only for fixed text, or switch to `textContent`.
- Check: the deployed site returns 404 for `/server.js` and `/node_modules/playwright/package.json`. `npm test` in `prototype-pwa` still passes.

### S8. Dev server can crash on a bad URL
- Where: `prototype-pwa/server.js`, `decodeURIComponent(...)`.
- Problem: a URL like `/%` throws and stops the process. It listens on 127.0.0.1 only, so only the local user can do it.
- Smallest fix: wrap the decode in try/catch and answer 400.
- Check: `curl http://127.0.0.1:4173/%` returns 400 and the server keeps running.

## New features: rules so no new hole appears

These come from `ideas/rattil-enhancement.md`. Each rule is a check for the work list.

1. Location (Adhan, Qibla): ask for coarse location only (`ACCESS_COARSE_LOCATION`). City level is enough for prayer times. Never ask for fine or background location. Keep the place in app-private storage. Never log it. Never send it over the network. Check: grep shows no network call that includes latitude or longitude.
2. Notifications and alarms: ask for `POST_NOTIFICATIONS` at the time the user turns reminders on, with an explanation first. For exact Adhan time, use `SCHEDULE_EXACT_ALARM` and handle the denied case with a clear message. Do not request more permissions than these.
3. Microphone: keep the promise that audio never leaves the phone. Check: grep shows the recorder only feeds the on-device recognizer. No audio file is written to storage and no recorded audio is sent over the network.
4. Model and riwaya downloads: only from pinned HTTPS hosts, only with a SHA-256 (see S2).
5. Notes: store in app-private storage, excluded from backup (S5), no sharing without a user tap.
6. Sound and animation files: free licenses, small files. No remote loading.
7. Dependencies: before adding a package, check its license and its latest release date. After adding, run `flutter pub outdated` and a known-vulnerability scan on `pubspec.lock`.

## Not verified yet

- Whether the installed Dart `HttpClient` blocks plain HTTP on Android. Test on a real phone or an emulator.
- Known vulnerabilities in `pubspec.lock` and `prototype-pwa/package-lock`. No scanner was run. Run `osv-scanner` or `flutter pub outdated` and read the result.
- Whether any log line prints user data. Run a search for `print(` and `debugPrint(` in `lib/`.
- Android build settings: `minSdk 24` is set. Check the final `targetSdk` for the new permission rules.
