# How to deploy a Rattil APK

GitHub builds the APK for you. You do not need Android Studio or the Android SDK on your PC.

The download link never changes:

- Most phones: https://github.com/zarsalene/Quran_AI_app/releases/latest/download/Rattil.apk
- Older 32-bit phones: https://github.com/zarsalene/Quran_AI_app/releases/latest/download/Rattil-32bit.apk

Each new release replaces what these links give.

## Way 1: automatic (merge to main)

1. Push your work to a branch.
2. Open a pull request. GitHub runs the build and the tests. No release is made.
3. Wait for the green check on the pull request.
4. Merge the pull request into `main`.
5. GitHub builds again and makes a release by itself. It takes about 15 to 25 minutes.
6. The links above now give the new APK.

## Way 2: by hand, from any branch (no merge)

Use this to put a test build on your phone before you merge.

**Important:** GitHub shows the **Publish** tick only after the new `build.yml` is on `main`. So the first release after this change must use Way 1 (merge). After that, Way 2 works from any branch.

1. Open https://github.com/zarsalene/Quran_AI_app/actions/workflows/build.yml
2. Click **Run workflow**.
3. Choose the branch, for example `rattil-enhancement-round`.
4. Tick **Publish the APKs as the latest release**.
5. Click the green **Run workflow** button.
6. Wait for the run to turn green. Then the links above give this build.

Without the tick, the run only builds and tests. The APK is then a file in the run page (section **Artifacts**, name `rattil-apks`). GitHub keeps it for a limited time.

## Install on the phone

1. Open the link on the phone.
2. Open the downloaded file and tap **Install**. Allow "Install unknown apps" if Android asks.
3. Open Rattil. The version is at the top right of the home screen: `0.2.<run number>`.

The speech model (about 73 MB) downloads the first time you use the teacher. Use Wi-Fi.

## Check before you deploy

- The run on the pull request is green (analyze and tests pass).
- You read `ideas/progress.md` for open decisions.
- A release on `main` is public. Anyone with the link can install it.

## If something goes wrong

| Problem | What to do |
|---|---|
| The run is red | Open the run, open the red step, read the last lines. Fix, push, wait for the new run. |
| A bad release is public | Open **Releases**, open the bad release, click **Delete**. The links then give the release before it. |
| The link gives an old APK | Open **Releases** and check which one is marked **Latest**. A manual run with "Publish" ticked on an old branch replaces it. |
| The phone says "App not installed" | The new APK has another signing key than the installed app. Uninstall Rattil once, then install again. Notes and bookmarks on the phone are lost. |
| The phone cannot update | The version number must go up. It does by itself: the run number is in the version. |

## How it works (for reference)

- File: `.github/workflows/build.yml`.
- Job `apk`: gets the code, gets the small model files, gets the qiraat text sources, runs `flutter analyze` and `flutter test`, builds the APKs, and keeps them as the artifact `rattil-apks`. It can only read the repository.
- Job `publish`: downloads the artifact and makes a GitHub Release with the tag `v0.2.<run number>`. It can write, and it runs only on `main` or on a manual run with "Publish" ticked.
- All outside actions are pinned to a full commit SHA. To update one, change the SHA and the tag in the comment on the same line.

## Known limits

- The APK is signed with the test key that is in the repository (`android/app/test-signing.p12`). This is open security item S1 in `ideas/security-fixes.md`. When you decide to fix it, the signing key moves to GitHub Secrets, and this page needs a new section.
- A Google Play release is out of scope. This is an APK on GitHub.

## Build on your own PC (optional)

You need Flutter 3.47.7, JDK 17, and the Android command-line tools. See `README.md`, section "Build locally". The command is:

```sh
python tool/fetch_models.py --bundled
python -I -X utf8 tool/data/build_qiraat.py
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

The APKs are in `build/app/outputs/flutter-apk/`.
