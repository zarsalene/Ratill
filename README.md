# Rattil (رتّل)

A free, offline Android app to read, memorize, and recite the Quran, with a recitation teacher that listens on the phone.

No ads, no account, no analytics. Audio never leaves the phone. The network is used only to download files: recitation audio, and the speech model the teacher needs once (about 73 MB, checked against a pinned SHA-256). Nothing about you is sent.

> Automatic feedback can be wrong. It does not replace a qualified teacher.

Status: in development. See [PLAN.md](PLAN.md).

## Install on a phone

1. On the phone, open https://github.com/zarsalene/Quran_AI_app/releases/latest/download/Rattil.apk
   (for an older 32-bit phone: `Rattil-32bit.apk` on the [latest release](https://github.com/zarsalene/Quran_AI_app/releases/latest)).
2. Open the downloaded file and tap Install. Allow "Install unknown apps" if Android asks.
3. Open Rattil (رتّل). The version is shown at the top right of the home screen.

## Build locally (command line, no Android Studio)

You need:
- Flutter SDK (stable, 3.47.7 is used in CI): https://docs.flutter.dev/get-started/install
- JDK 17
- Android command-line tools: https://developer.android.com/studio#command-line-tools-only
- Python 3.10 or later (for the model and data scripts)

Steps:

```sh
# Android SDK packages (once)
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
flutter config --android-sdk <path-to-android-sdk>
flutter doctor --android-licenses

# Model files in the APK: downloaded and checked against pinned SHA-256 sums
# (without --bundled it also fetches the 72 MB speech model, for tests)
python tool/fetch_models.py --bundled

flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

The APKs are in `build/app/outputs/flutter-apk/`.

## Repository

| Path | What |
|---|---|
| `lib/core/align` | The teacher's alignment and scoring (pure Dart, unit tested) |
| `lib/core/asr` | Mic, voice activity detection, on-device speech recognition in an isolate |
| `tool/spike` | First test of the speech model against the reference phonemes |
| `tool/fetch_models.py` | Downloads and verifies the on-device models |
| `data/raw` | Quran source files, byte-exact, pinned in `data/CHECKSUMS` |
| `prototype-pwa` | An earlier web prototype. Not part of the app |

## Sources and credits

- Quran text: [Tanzil](https://tanzil.net) Uthmani text (CC BY 3.0, verbatim), and the KFGQPC Hafs text and font through [QUL](https://qul.tarteel.ai).
- Phonetic reference: [quran-transcript](https://github.com/obadx/quran-transcript) by obadx.
- Speech model: zipformer_p-arabic-v2 by Muno459 / Quran-Lab, under the Quran-Lab No-Profit License 1.1. It may be used only in apps that are free for their users. The license file ships in the app.
- Voice activity detection: [Silero VAD](https://github.com/snakers4/silero-vad) through [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx).
- Recitation audio: [everyayah.com](https://everyayah.com).
- Translations (verbatim, pinned in `data/CHECKSUMS`): Saheeh International (English) and Muhammad Hamidullah (French), from [Tanzil.net](https://tanzil.net). Redistribution terms of these two files: not verified (the Tanzil files carry no license text).
- Prayer times: [adhan_dart](https://pub.dev/packages/adhan_dart) (MIT), computed on the phone. Tunisia method: Fajr 18, Isha 18 (checked against the AlAdhan API for Tunis and Makkah).
- Adhan: CC0 recording [File:Adhan.ogg](https://commons.wikimedia.org/wiki/File:Adhan.ogg) on Wikimedia Commons (user Aishatu98). The CC0 mark is the uploader's claim on Commons.
- Sound effects: made by `tool/make_sounds.py` (plain tones, no outside license).
- Location (coarse, once) and notifications stay on the phone. Nothing about you is sent anywhere.

## Download website

The trilingual Rattil download website is in [`prototype-pwa`](prototype-pwa/README.md). To run it locally, open a terminal in that folder and run `npm start`. The README there also covers GitHub Pages and Cloudflare Pages deployment.
