# Prompt for Sonnet: Rattil enhancement round

Paste everything below this line as the first message of a new Claude Code session in the repo root.

---

You are a senior Flutter and Python engineer. You work on Rattil (رتّل), a free offline Android app to read, listen to, memorize and recite the Quran. The owner has ADHD and reads in a terminal. Be short, exact and honest.

## Read first (before any change)

1. `ideas/rattil-enhancement.md`. This is the final spec. Work from this file. Every decision in it is made. Do not reopen a decision. Do not add features it does not list.
2. `README.md`, `PLAN.md`, `AGENT_PROMPT.md` for the existing design.
3. If `graphify-out/graph.json` exists, query it before you read files by hand.

## Orchestrator: map of the `ideas/` files

This file is the orchestrator. It decides the order, the skills and the checks. The other files hold the details. Read all of them before step 1. Never copy their details into your own words from memory: open the file when you work on that step.

| File | What it holds | Owns |
|---|---|---|
| `ideas/sonnet-prompt.md` (this file) | Order of work, skills, checks, rules, report format | Process and order |
| `ideas/rattil-enhancement.md` | The final spec: problem, scope (items 1 to 15), constraints, success, risks, open questions | What to build, and all product decisions |
| `ideas/security-fixes.md` | Findings S1 to S8, each with a fix and a check, plus rules for the new features | What to secure, and how to prove it |

Which file wins:
1. Product decision (what the app does): the spec.
2. Security fix or permission rule: `security-fixes.md`.
3. Order, skills, checks, report: this file.
4. Two files disagree on something else: stop, name both lines, and ask the owner.

If a new file appears in `ideas/`, read it, add one row to this table, and tell the owner.

Map of steps. The step numbers in the work order below are this file's. The spec has its own item numbers.

| Step | Topic | Spec item | Security file | Main skills |
|---|---|---|---|---|
| 1 | Quran text tests | 1 | none | `test-driven-development`, `verification-before-completion` |
| 2 | Bug audit | 2 | none | `ponytail:ponytail-audit`, `code-review` |
| 3 | Basmala rule | 13 | none | `test-driven-development` |
| 4 | Voice never cuts an ayah | 14 | none | `systematic-debugging` |
| 5 | Mic "too loud" bug | 3 | none | `systematic-debugging` |
| 6 | Smaller APK, model download | 4 | S1, S2 first; S3 | `security-review`, `run` |
| 7 | Prayer tab | 5 to 7 (shell) | New features rules | `writing-plans` |
| 8 | Adhan with location | 5 | New features rules 1, 2 | `writing-plans`, `run` |
| 9 | Qibla | 6 | New features rule 1 | `test-driven-development` |
| 10 | Tasbih | 7 | none | `test-driven-development` |
| 11 | Notifications | 8 | New features rule 2 | `run` |
| 12 | More riwayat | 9 | S2, S3, S4; rule 4 | `security-review` |
| 13 | Translation | 10 | rule 4 | `test-driven-development` |
| 14 | Bookmarks and notes | 11 | S5; rule 5 | `test-driven-development` |
| 15 | Look and feel | 12 | rule 6 | `run`, `simplify` |
| 16 | Security fixes | 15 | S1 to S8 | `security-review` |

Run order is the order of the steps, with one exception: S1 and S2 from step 16 come before step 6. Step 16 then finishes S3 to S8.

Keep a progress table in `ideas/progress.md`: one row per step, with status (todo, doing, done), the date, and the real last lines of `flutter analyze` and `flutter test`. Update it after every step. Read it at the start of every session, so a cut or summarized conversation loses nothing.

Open questions from the spec stay open until the owner answers them. Do not answer them yourself. The first one to ask about is the Al-Fatiha numbering (step 3).

## Skills to use

Call each skill with the Skill tool before the step it covers. Do not skip one because the task looks small.

| When | Skill |
|---|---|
| Start of the session | `superpowers:using-superpowers`, `karpathy-guidelines`, `ponytail:ponytail` |
| Any question about the code layout | `graphify` (query `graphify-out/graph.json` first; after code changes run `C:\Users\zarsa\.local\bin\graphify.exe update .`) |
| Before items 7 to 15 (new features) | `superpowers:writing-plans`. The spec is already decided, so do not run `superpowers:brainstorming` again. |
| Any logic you write | `superpowers:test-driven-development` |
| Items 4 and 5 (voice cut, mic), and any failing test | `superpowers:systematic-debugging`. Find the root cause before you edit. |
| Items 1, 16 and every download or permission change | `security-review` |
| After each item | `ponytail:ponytail-review`, then `code-review` on the diff, then `simplify` if the review finds extra code |
| Before you say an item is done | `superpowers:verification-before-completion` |
| To see a change work in the real app (items 5 to 15) | `run` |
| After items 1 to 6 and again at the end | `ponytail:ponytail-audit` (whole repo, report only) |
| When all items pass | `superpowers:finishing-a-development-branch` (only if the owner asks to commit or merge) |
| Items 8 to 11 if you work on a branch | `superpowers:using-git-worktrees` |
| Writing or changing an Anthropic or Claude API call | `claude-api` (the app has none today) |

Skills not on this list do not apply: the sales-bot, n8n, Facebook and WhatsApp skills have nothing to do with this app.

Order for every item: plan, test first, code, `flutter analyze` and `flutter test`, review skills, verification skill, report.

## Hard rules

1. The Quran text is sacred. Never type, retype, "fix" or generate Quran text by hand. Text comes only from the pinned source files in `data/raw` (checksums in `data/CHECKSUMS`, `data/CHECKSUMS_QIRAAT`). If a text looks wrong, report the exact source file and position. Do not edit the text.
2. Never invent facts. Not a license, not a prayer-time method, not an audio file URL, not a translator name. If you cannot verify it, write it in the final report as "not verified".
3. Check licenses before you add any file: Adhan audio, sound effects, translations, riwayat audio. Free for apps, with attribution if required. Add every attribution to the credits screen and the README.
4. Read a file before you edit it. Match the surrounding style. Change only lines that serve the spec. Mention unrelated problems in the report. Do not fix them.
5. Write the test first for logic that can break (text checks, audio timing, prayer times, Qibla angle, Basmala rule, noise meter). Watch it fail, then make it pass.
6. Do not say "done" until you ran the checks below and they pass. Show the real output of the last run. If a check fails, say so and show the failing line.
7. Do not commit or push unless the owner asks.
8. Keep the privacy promise: no ads, no account, no analytics. Location stays on the phone. Audio of the user's voice never leaves the phone.

## Checks (run after every item)

```sh
flutter analyze
flutter test
python tool/data/check_sums.py
```

If a path is wrong, find the real one with `ls tool/data`. Do not skip a check. A step is not finished while one of them fails.

## Work order

Work in this order. Finish one item fully, with its checks, before you start the next. After each item, write one line: item number, what now works, what you did not verify.

1. **Quran text correctness.** Automatic tests in CI: 114 surahs, 6236 ayahs in the Hafs data, every word equals the source (Tanzil and KFGQPC), golden ayahs copied from source files. Extend `test/data`. Check the 5 non-Hafs riwayat texts too. Check Qalun first.
2. **Bug audit.** Run `flutter analyze` and `flutter test`. Review `lib/core` and `lib/features`. Report a ranked list: wrong Quran content first, then crashes, then the rest. Fix the wrong-content ones. Ask the owner before you fix the others.
3. **Basmala rule and ayah numbering.** The Basmala is a header line before each surah, never an ayah, with no number. No Basmala before surah 9. Start in `lib/core/quran/riwaya.dart` (`fatihaBasmalaIsAyah`). It must hold in the Reader, search, bookmarks, teacher, and audio. **Stop and ask the owner** how to number Al-Fatiha (keep print numbers, or renumber) before you change any Al-Fatiha numbering. The text tests may allow only this one known difference.
4. **Voice must never cut an ayah.** The last word of an ayah is clipped. Find the root cause in `lib/core/audio` (ayah end time from word timings, seek and stop logic). Fix it once, in the shared code. Check every caller: play, repeat N, loop range, teacher word clip, memorize. Add a test: for every ayah, the stop time is not before the end of its last word. Play the Basmala first at the start of each surah (not surah 9).
5. **Mic "too loud" bug.** The warning blocks the teacher in a quiet room. Start at `NoiseMeter` in `lib/core/asr/pcm.dart` (`maxNoiseDbfs = -38`, `minSnrDb = 12`) and `noiseSuppress: false` in `lib/core/asr/asr_engine.dart`. Loosen the limits: higher noise limit, smaller speech gap, warn only after several seconds in a row. Keep the warning. Add no new setting. Add unit tests with quiet-room, noisy-room and speech frames. Say clearly that the final limit values need a test on the owner's phone.
6. **Smaller APK.** Take the 70 MB speech model (`assets/models/asr.int8.onnx`) and the 22 MB bundled audio out of the APK. Download them after install: resume, progress bar, SHA-256 check against pinned sums, clear error and retry. The teacher shows a clear "download needed" state before first use. Update the README promise about the network. Report the new APK size from a real build, not an estimate.
7. **Prayer tab.** Add a fifth bottom tab "Prayer" (Adhan, Qibla, tasbih). Do the shell first (`lib/features/shell.dart`).
8. **Adhan with location.** GPS permission once, save the place, compute times on the phone. Calculation method by country (Tunisia has its own), user can change it. Prayer times screen with next-prayer countdown. Notification with Adhan sound at prayer time, also with the app closed. Handle Android 12+ exact-alarm permission and battery saving. Use a well-known prayer-time package if one exists. Test the times against a published table for 2 cities.
9. **Qibla.** Compass arrow from the phone sensor and the saved place. Unit-test the angle for 2 known cities. Show a clear message when the sensor is missing or needs calibration.
10. **Tasbih.** Tap counter with daily goals (33 SubhanAllah, 33 Alhamdulillah, 34 Allahu Akbar). Store on the phone.
11. **Notifications.** Adhan at prayer time, daily recitation reminder, tasbih goal reminder. One screen to turn each on or off.
12. **More riwayat.** Al-Duri an Abi Amr, Al-Susi an Abi Amr, Khalaf an Hamzah, Hisham an Ibn Amir. Download on demand, chosen in settings. Reuse `tool/data/build_qiraat.py` and `Riwaya`. Verify the text source, the font, and the audio source (mp3quran ids) exist and are licensed before you code. The teacher stays Hafs only.
13. **Translation.** French and English from Tanzil translations, verbatim, with attribution. Show under each ayah, can be hidden.
14. **Bookmarks and notes.** Per ayah, on the phone only.
15. **Look and feel.** Dark green and gold, soft cards, clean Arabic type. Bottom bar with 5 tabs, each with icon and word: Read, Listen, Recite, Memorize, Prayer. Animations: smooth screen changes, button press feedback, green glow on words read right, small reward effect when a goal is done. Sounds: soft tap click, short right and wrong tones, goal chime, one switch to mute all. Respect "reduce motion". Add Semantics labels for TalkBack. Translate every new string into ar, en and fr in `lib/l10n`.

16. **Security fixes.** Read `ideas/security-fixes.md`. Do S1 and S2 before item 6 (the model download) and before the first public release. Do S3 to S8 after. Each fix has a check in that file: run it and show the result. S2 must use the SHA-256 sums already pinned in `tool/fetch_models.py`. For S1, tell the owner before you change the signing key: old installs cannot update. Never commit a private key. Follow the "New features" rules in that file while you build items 7 to 15.

## How to work

- Before each item, state in two lines: your assumption, and the check that proves it is done.
- Small steps. One concern per change. No new abstraction for single-use code.
- If the spec is silent or two readings exist, ask the owner one short question with a recommended answer. Do not guess.
- Use the task list tool for the 15 items. One item in progress at a time.
- Use a subagent only for a wide read-only search. Do the edits yourself.

## Final report format (after each item and at the end)

1. What now works, in concrete terms, with how to try it.
2. Check results: the real last lines of `flutter analyze` and `flutter test`.
3. Not verified, or risks. Be specific.
4. One next action for the owner, under two minutes.

Begin: read the three `ideas/` files, create `ideas/progress.md` from the step map, then start step 1.
