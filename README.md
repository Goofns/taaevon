# Taaevon

Cross-platform (iOS + Android) **dual-curriculum** educational app — Mathematics
and Language, Pre-K through Post-Graduate — built with Flutter in an **Abstract
Geometric Minimalism** style (zero characters, mascots, or faces).

Full product & technical spec: [`TAAEVON_PRD_FULL.md`](TAAEVON_PRD_FULL.md).

## What's in this scaffold

This repo materializes the PRD's Phase 1–2 foundations into runnable code:

| Area | Path |
|------|------|
| Geometric background layer | [`lib/features/background/`](lib/features/background/) |
| Micro-learning Fact Engine (isolated BLoC) | [`lib/features/fact_engine/`](lib/features/fact_engine/) |
| Language track (lexicon entity + SM-2) | [`lib/features/language/`](lib/features/language/) |
| Vocabulary review (SM-2 spaced repetition) | [`lib/features/review/`](lib/features/review/) |
| Math track (problem bank + live DDC demo) | [`lib/features/math/`](lib/features/math/) |
| Polygon Polyglot activity (playable) | [`lib/features/activity_engine/polygon_polyglot/`](lib/features/activity_engine/polygon_polyglot/) |
| Isometric Tessellation activity (playable) | [`lib/features/activity_engine/isometric_tessellation/`](lib/features/activity_engine/isometric_tessellation/) |
| Matrix Vector Track activity (playable) | [`lib/features/activity_engine/matrix_vector_track/`](lib/features/activity_engine/matrix_vector_track/) |
| Dual-curriculum sync engine (DDC + injector) | [`lib/features/sync_engine/`](lib/features/sync_engine/) |
| Progress tracking (root cubit, persisted, home daily goal) | [`lib/features/progress/`](lib/features/progress/) |
| Settings & accessibility (persisted goal + reduce-motion) | [`lib/features/settings/`](lib/features/settings/) |
| First-run onboarding (gated on a persisted flag) | [`lib/features/onboarding/`](lib/features/onboarding/) |
| Daily streak (persisted, consecutive-day logic) | [`lib/features/streak/`](lib/features/streak/) |
| Achievements (derived from progress + streak, no extra storage) | [`lib/features/achievements/`](lib/features/achievements/) |
| About screen (design ethos + live asset stats) | [`lib/features/about/`](lib/features/about/) |
| Design tokens (colour / type / spacing) | [`lib/core/constants/`](lib/core/constants/) |
| Home / module-selection screen | [`lib/features/home/`](lib/features/home/) |
| SQLite schema (facts + lexicon + DDC) | [`database/schema.sql`](database/schema.sql) |
| Fact + lexicon seeding pipelines | [`tools/`](tools/) |
| Curated starter datasets | [`assets/data/`](assets/data/) |

## Project location note

OneDrive nested this project one level deep. The real project root — the folder
containing `pubspec.yaml` — is **`…\OneDrive\Documents\Taaevon\Taaevon\`** (the
inner `Taaevon`). Open *that* folder in your IDE and run Flutter commands from
there. The outer `…\Documents\Taaevon\` only contains this inner folder. You may
want to move the inner contents up a level to flatten it.

> Tooling note: on this machine Git Bash and native Windows tools resolved the
> OneDrive path differently. If a script "can't find" `lib/`, point it at the
> absolute inner path.

## Run the app

```bash
flutter pub get
flutter run
```

## Building an APK

The repo ships the Dart app (`lib/`) and `pubspec.yaml` but **not** the
platform folders (`android/`, `ios/`). Generate them, then build:

```bash
flutter create --platforms=android .   # adds android/ (keeps your lib/)
flutter pub get
flutter analyze                        # fix any type errors first
flutter build apk --release            # -> build/app/outputs/flutter-apk/app-release.apk
```

A release build with no keystore is auto-signed with a debug key: it installs on
a device for testing but is not Play Store ready.

**No local Flutter install?** Push to a GitHub repo and the `build-apk` job in
[CI](.github/workflows/flutter.yml) does all of the above and uploads the APK as
a downloadable artifact (Actions run → **Artifacts** → `taaevon-apk`). That job
only succeeds once the Dart compiles cleanly, so it doubles as the compile check.

On first launch the app shows a one-time **onboarding** screen; tapping *Get
started* sets a persisted flag, and every launch after goes straight to home. A
`RootGate` waits for settings to hydrate before deciding, so returning users
never see onboarding flash.

Tap **Show a fact** to see the micro-learning interstitial pull a unique,
complexity-filtered fact from the bundled dataset. Facts also appear **during
navigation**: opening the Mathematics or Language track uses `pushWithFact`,
which requests a fresh fact and cross-fades it into the destination over the
route transition — the loading-engine moment from PRD §6.3 that turns dead time
into a learning beat. The `FactBloc` lives at the app root so any route can show
one. The faded geometric background is deterministic per user id and renders
once (cached behind a `RepaintBoundary`).

Tap the **LANGUAGE** track card to choose a target language (the picker lists
only languages present in the lexicon — currently German, Spanish, French,
Italian, Japanese, Mandarin Chinese, Russian, and Arabic), then
play **Polygon Polyglot**: translate the prompt word by tapping the right tile;
each correct answer locks a vertex of the
polygon and a wrong one distorts it. Solving every vertex fills the shape — a
purely geometric engagement loop (no characters or faces), wired to the real
bundled lexicon.

Choosing a language also offers **Review vocabulary** — a spaced-repetition
session driven by the **SM-2** scheduler over the words due today. You reveal each
translation and grade recall (Again / Hard / Good / Easy); the grade feeds SM-2,
and each word's schedule (ease, interval, due date) **persists** so reviews come
back at the right time. This is what finally connects the tested SM-2 logic to a UI.

Completing any activity (solving a Polygon Polyglot polygon, filling a
tessellation, or reaching a vector target) records a completion in the root
`ProgressCubit`, and the **Daily goal** bar on the home screen advances toward
the goal of 5. Progress is **persisted** through a `ProgressStore` (the default
`SharedPrefsProgressStore` saves the completion map to `shared_preferences`), so
the daily goal **survives app restarts**. The cubit hydrates saved progress at
startup; the store is an injectable interface, so tests use an in-memory fake and
a future build could swap in SQLite/Hive without touching the cubit.

The **gear icon** on the home screen opens **Settings** (PRD §14): the daily goal
is adjustable (1–20, and the home bar updates live) and a **reduce-motion** toggle
disables non-essential animations like the polygon shake. Settings persist the
same way (`SharedPrefsSettingsStore`). The goal lives in `SettingsCubit`, kept
separate from completion counts in `ProgressCubit`.

Tapping the **Daily goal** bar opens the **Your Progress** screen — total
completions, the goal bar, and a per-activity breakdown with geometric bars (the
most-practiced activity is highlighted), plus a reset. It reads the same
persisted `ProgressCubit`, so the history reflects everything you've completed.
A **Day streak** card shows consecutive days practised — completing any activity
records the day via `StreakCubit`, which increments on consecutive days and
resets after a gap (pure date logic in `StreakCalculator`, with an injectable
clock for testing). A **View achievements** button opens the **Achievements**
screen — ten geometric-badge milestones (totals, streaks, and per-activity
mastery) evaluated live against an `AchievementSnapshot` built from the same two
cubits, so achievements add no storage of their own. Locked badges show a
progress bar toward their threshold; the header counts how many are unlocked.

Tap the **MATHEMATICS** track card to open the **domain matrix** (PRD §7.2) — a
geometric grid of domains from Numeracy to Abstract Algebra across three tiers,
with locked tiles shown as nested-square glyphs. Pick **Calculus** (band 3.0)
with the default beginner Japanese (A1) and the cross-domain injector poses a
calculus problem with its operands rendered as Japanese number-words (e.g.
`f′(さん)`), surfacing the vocabulary in a chip row. Answer correctly and the DDC
engine raises the band; miss and it recalibrates down. Lower-tier domains
(band < 3) run in parallel mode, so their operands stay as digits.

From the domain matrix, the **Isometric Tessellation challenge** button opens the
third activity: solve an arithmetic problem to earn a geometric tile, then tap an
empty cell adjacent to your pattern to place it. Fill the panel to complete the
tessellation — math practice and spatial reasoning in one geometric loop.

The **Matrix Vector Track** button opens the most directly dual-curriculum
activity: each grid column is labelled with a target-language number-word, and
the goal names the target column *in that language* (e.g. "column さん"). You
must read the number-word to identify the column, then steer the vector there
with the directional pad — coordinates and vocabulary at once.

## Seed / rebuild the fact database

The Python pipeline validates every fact (structure, category whitelist, source
format, length, complexity bounds) before inserting into SQLite:

```bash
python tools/seed_facts.py    assets/db/taaevon.db assets/data/facts_seed.json
python tools/seed_lexicon.py  assets/db/taaevon.db assets/data/lexicon_seed.json
python tools/validate_data.py assets/data/facts_seed.json assets/data/lexicon_seed.json
```

`validate_data.py` runs deeper checks than the seeders — duplicate detection,
numeral value consistency (e.g. that `diez` maps to 10), and coverage (numbers
1–3 present in every target language). It currently reports 500 facts across all
12 categories and 236 lexicon words across eight target languages — German,
Spanish, French, Italian, Japanese, Mandarin Chinese, Russian, and Arabic. These
exercise all four script families (Latin, CJK, Cyrillic, Arabic) and both writing
directions (Arabic is `rtl`), plus the `has_tones` flag (Mandarin). Coverage
includes numbers 1–10, everyday vocabulary, conversational phrases, and the PRD's
higher lexical registers (academic, formal, technical, and slang).

> The Polygon Polyglot and Matrix Vector Track screens wrap their content in a
> `Directionality` keyed off `LanguageCatalog.isRtl(targetLanguage)`, so Arabic
> renders right-to-left. (The Math problem and Tessellation screens always launch
> in Japanese, so they remain LTR.)

### On the "10,000 facts" target — honest status

`facts_seed.json` is a **curated, genuinely-verifiable starter set** (500 facts
spanning all 12 categories and all 5 complexity tiers), not the full 10,000. Each
entry cites a real institutional source. Reaching
10,000 with the PRD's "100% factually accurate" bar is a **content-operations
effort**, not something to auto-generate — fabricating thousands of facts with
invented citations would violate that bar. The pipeline here is what each fact
flows through:

1. Author/import candidate fact with a real source.
2. `seed_facts.py` enforces the machine-checkable contract.
3. Human + source verification pass (the part that cannot be automated).
4. Insert; ship in the bundled DB.

The seed sources currently cite institutions at the domain level (e.g. NASA,
NOAA, BIPM, Britannica). A verification pass should deepen these to specific
article URLs or DOIs.

## Architecture notes

- **State management:** `flutter_bloc`, strict unidirectional flow. `FactBloc`
  shares no mutable state with curriculum BLoCs (PRD §11.2).
- **Offline-first:** the scaffold serves facts from a bundled JSON asset for
  zero-setup runnability; production swaps this for `sqflite` (bundled
  `taaevon.db`) fronted by a Hive hot-cache, per PRD §6/§11.3.
- **No anthropomorphic assets:** all glyphs are pure geometry (see the polygon
  painters in the home screen and background).

## Dual-curriculum sync engine

The signature feature lives in [`lib/features/sync_engine/`](lib/features/sync_engine/):

- **SM-2 spaced repetition** ([`spaced_repetition.dart`](lib/features/language/domain/spaced_repetition.dart)) — schedules language review.
- **Dynamic Difficulty Calibration** ([`dynamic_difficulty_calibrator.dart`](lib/features/sync_engine/dynamic_difficulty_calibrator.dart)) — a difficulty step function plus the cross-domain injection-mode decision matrix (PRD §10.2).
- **Interlocking injector** ([`interlocking_progression.dart`](lib/features/sync_engine/interlocking_progression.dart)) — renders a post-grad math prompt with beginner-script number-words, e.g. `x₀ = さん (san) = 3`, surfacing vocabulary while the learner works at their true math level.

### Verification status

`flutter` is not assumed to be on every machine. The algorithm cores (SM-2
ease deltas and intervals, the DDC step function and decision matrix, and the
injector substitution) were verified numerically with Python oracles, and the
injector was run against the **seeded SQLite lexicon** to confirm the さん
substitution end-to-end. The Dart unit tests in [`test/`](test/) assert those
exact values — run them with `flutter test` on a machine with the SDK.

## Tests

```bash
flutter test
```

| Suite | Covers |
|-------|--------|
| [`fact_bloc_test.dart`](test/fact_bloc_test.dart) | no-repeat delivery, complexity ceiling |
| [`spaced_repetition_test.dart`](test/spaced_repetition_test.dart) | SM-2 ease/interval/lapse/floor |
| [`review_schedule_test.dart`](test/review_schedule_test.dart) | due-date logic, grading, round-trip |
| [`review_cubit_test.dart`](test/review_cubit_test.dart) | session over due words, complete, empty |
| [`ddc_test.dart`](test/ddc_test.dart) | difficulty step function + injection matrix |
| [`interlocking_progression_test.dart`](test/interlocking_progression_test.dart) | cross-domain number-word injection |
| [`polyglot_round_factory_test.dart`](test/polyglot_round_factory_test.dart) | option generation, uniqueness, clamping |
| [`polyglot_bloc_test.dart`](test/polyglot_bloc_test.dart) | vertex locking, completion, distortion, starvation guard |
| [`math_problem_bank_test.dart`](test/math_problem_bank_test.dart) | arithmetic→calculus answer computation, band→tier |
| [`math_bloc_test.dart`](test/math_bloc_test.dart) | live injection, correct/wrong band recalibration |
| [`math_domain_catalog_test.dart`](test/math_domain_catalog_test.dart) | band↔tier invariant, unlocked entry points |
| [`tessellation_board_test.dart`](test/tessellation_board_test.dart) | placement adjacency/bounds rules |
| [`tessellation_bloc_test.dart`](test/tessellation_bloc_test.dart) | earn tile, place, no-op without credit, complete |
| [`vector_track_test.dart`](test/vector_track_test.dart) | movement clamping, atTarget |
| [`vector_track_bloc_test.dart`](test/vector_track_bloc_test.dart) | column number-words, navigate to target → complete |
| [`language_catalog_test.dart`](test/language_catalog_test.dart) | distinct target languages, display-name fallback |
| [`progress_cubit_test.dart`](test/progress_cubit_test.dart) | per-activity counts, progress fraction, most-completed, persistence, reset |
| [`settings_cubit_test.dart`](test/settings_cubit_test.dart) | goal clamping, persist/hydrate, onboarding flag, round-trip |
| [`streak_test.dart`](test/streak_test.dart) | start / same-day / consecutive / gap / month-boundary |
| [`streak_cubit_test.dart`](test/streak_cubit_test.dart) | clock-driven recording, persist/hydrate |
| [`achievement_test.dart`](test/achievement_test.dart) | threshold boundaries, metric independence, unlocked count/ids, catalogue integrity |
