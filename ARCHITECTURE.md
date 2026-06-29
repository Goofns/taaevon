# Taaevon — Architecture

This document maps the codebase so a new contributor can navigate it quickly. It
reflects what is actually in `lib/` and `test/` today (**75 Dart source files,
27 test files / 115 tests**) and the project's current state: **it compiles and
CI is green** (`flutter analyze` + tests + an Android APK build run on every
push). For product scope see [TAAEVON_PRD_FULL.md](TAAEVON_PRD_FULL.md); to run
it see [README.md](README.md).

## 1. Layering

Each feature follows a light Clean-Architecture split:

```
presentation/   Flutter widgets, CustomPainters, screens (no business logic)
bloc/ | cubit/  flutter_bloc — events in, states out, unidirectional
domain/         pure entities + rules (no Flutter imports) — the testable core
data/           datasources + repositories + stores (assets/prefs now)
```

The **pure `domain/` layer is where the logic lives and where the tests aim** —
no Flutter dependency, so its rules (SM-2, DDC, placement, navigation, streak
dates) are verifiable in isolation and were cross-checked against Python oracles.

Shared code lives under `lib/core/`: `constants/` (design tokens), `theme/`,
`utils/` (e.g. `date_key.dart`), `data/` (`json_prefs.dart` — the shared guarded
prefs persistence), and `widgets/` (e.g. `numeric_answer_field.dart`).

## 2. Feature map (`lib/features/`)

| Feature | Responsibility | Key files |
|---------|----------------|-----------|
| `background/` | Static geometric backdrop (iso grid + polygon field), deterministic per user | `geometric_background_painter.dart`, `background_seed_generator.dart` |
| `fact_engine/` | Micro-learning interstitial; isolated BLoC; decode offloaded to a background isolate | `bloc/fact_bloc.dart`, `data/fact_local_datasource.dart`, `presentation/fact_route.dart` |
| `language/` | Universal lexicon entity, SM-2 scheduler, language catalog + picker | `domain/spaced_repetition.dart`, `domain/language_catalog.dart` |
| `math/` | Problem bank (arithmetic→calculus), live problem BLoC, domain matrix | `domain/math_problem_bank.dart`, `bloc/math_bloc.dart` |
| `sync_engine/` | **Signature feature**: DDC step function + cross-domain injector | `dynamic_difficulty_calibrator.dart`, `interlocking_progression.dart` |
| `activity_engine/polygon_polyglot/` | Vertex-locking translation game | `bloc/polyglot_bloc.dart` |
| `activity_engine/isometric_tessellation/` | Solve-to-earn-tile board game | `domain/tessellation_board.dart`, `bloc/tessellation_bloc.dart` |
| `activity_engine/matrix_vector_track/` | Vector grid navigation + number-words | `domain/vector_track.dart`, `bloc/vector_track_bloc.dart` |
| `review/` | SM-2 spaced-repetition vocabulary review session | `bloc/review_cubit.dart`, `domain/review_schedule.dart` |
| `progress/` | Persisted completion tracking + stats screen | `cubit/progress_cubit.dart`, `presentation/stats_screen.dart` |
| `streak/` | Consecutive-day practice streak (pure date logic, injectable clock) | `domain/streak.dart`, `cubit/streak_cubit.dart` |
| `achievements/` | Derived milestone badges (no extra storage) | `domain/achievement.dart`, `presentation/achievements_screen.dart` |
| `settings/` | Daily goal + reduce-motion + onboarding flag (persisted) | `cubit/settings_cubit.dart` |
| `onboarding/` | First-run intro, gated by a persisted flag via `home/root_gate.dart` | `presentation/onboarding_screen.dart` |
| `about/` | Design ethos + live dataset counts | `presentation/about_screen.dart` |
| `home/` | Module selection, track cards, daily-goal bar, root gate | `presentation/home_screen.dart`, `presentation/root_gate.dart` |

## 3. State management

- **Unidirectional flow** via `flutter_bloc`. UI dispatches events; BLoCs emit
  states; `BlocBuilder`/`BlocConsumer` rebuild. Dart-3 **sealed states +
  exhaustive `switch` expressions** drive the screens.
- **Root-scoped (above `MaterialApp`, in `main.dart`):** `ProgressCubit`,
  `SettingsCubit`, `StreakCubit`, and the isolated `FactBloc`. They live for the
  app's lifetime, hydrate from persistence at startup, and any pushed route can
  read them.
- **Screen-scoped:** each activity (`PolyglotBloc`, `TessellationBloc`,
  `VectorTrackBloc`, `MathBloc`) and `ReviewCubit` own a BLoC provided at their
  screen and disposed on pop. Async init that emits after an `await` is guarded
  with `if (isClosed) return;` (or uses the `on<Event>` Emitter, which the
  framework cancels on close) so a back-navigation mid-load cannot crash.
- `main()` runs under `runZonedGuarded` + `FlutterError.onError`, so a stray
  uncaught async error is logged rather than silently killing the app.

## 4. The dual-curriculum sync engine (signature)

```
LexiconEntry.mathExtractedValue ──┐
                                  ▼
DynamicDifficultyCalibrator.decideInjectionMode(mathBand, cefr)
                                  │  (PRD §10.2 matrix)
                                  ▼
InterlockingProgression.inject(template, bindings, targetVocab, mode)
                                  │
                                  ▼
   "Prove f continuous at x0 = さん"   +  glossary [さん (san) = 3]
```

`MathBloc` wires these live: it picks a problem for the current band, asks the
calibrator for an injection mode, runs the injector, and after each answer feeds
accuracy back into `DynamicDifficultyCalibrator.calibrate` to move the band. The
marquee path (band 3.0 + CEFR A1 → `fullInterlock`) renders post-grad math with
beginner-script number-words.

## 5. Data, persistence & offline strategy

- **Content:** datasources load bundled JSON (`assets/data/facts_seed.json` ≈500
  facts, `lexicon_seed.json` ≈236 words / 8 target languages) into memory. The
  facts decode + map runs on a **background isolate via `compute()`** so the
  ~188KB parse never blocks the UI thread (PRD §6).
- **User state:** progress, settings, streak, and review schedules persist via
  `shared_preferences` behind an `XStore` interface (`InMemory*` + `SharedPrefs*`
  implementations). All four SharedPrefs stores share `core/data/json_prefs.dart`
  (`loadJsonMap`/`saveJsonMap`), whose **guarded decode clears any corrupt/partial
  value** so a bad write can never wedge the app on its loading spinner.
- **Production (PRD §11.3):** swap datasources to `sqflite` over the bundled
  `taaevon.db` (schema in `database/schema.sql`), fronted by a Hive hot-cache.
  Repository/store interfaces are unchanged across the swap.
- **Seeding pipelines** (`tools/seed_facts.py`, `seed_lexicon.py`) validate every
  record before insert — the path each record takes toward the 10,000-fact goal.

## 6. Accessibility & performance

- **Geometry-only visual identity** (zero characters/mascots): every glyph is a
  `CustomPainter`. Interactive colours are WCAG-AA, enforced by a contract check
  (§7).
- **Screen-reader support:** answer outcomes, the vector position, and the fact
  interstitial are `Semantics(liveRegion: true)`; geometric tap surfaces
  (tessellation board, daily-goal, achievements) carry button roles/labels so
  the activities are operable non-visually.
- **Text scaling** is clamped to ≤1.5× in `main.dart`. Full WCAG-1.4.4 200%
  support is a known limitation (§9).
- **Performance:** 120Hz-oriented; the fact decode is off-isolate; painters use
  `shouldRepaint` and the background is a static seeded painter.

## 7. Testing & verification strategy

Verification is layered so most of it runs without a local Flutter SDK:

1. **Unit tests** (`test/`) assert the `domain/` rules and BLoC/cubit flows
   (incl. regression tests for the fixed crashers: corrupt-prefs, emit-after-close).
2. **Widget tests** pump the real tree (app boot, language picker, all four
   gameplay screens) — they exercise the real asset bundle and CustomPainters,
   catching device-class bugs the stubbed unit tests can't.
3. **Python oracles** independently confirm the numeric cores (SM-2, DDC,
   placement, navigation, injector) — the Dart mirrors those exact values.
4. **Static checkers** (`scratchpad/`): delimiter/import structural audit,
   cross-file symbol resolution, constructor-arg checks.
5. **CI** (`.github/workflows/flutter.yml`) on every push: `flutter analyze` +
   `flutter test` + an APK build, plus four **deterministic contract checks**
   that guard the device-only bug classes:
   - `tools/check_data_shape.py` — every JSON record matches the Dart `fromJson`.
   - `tools/check_assets_declared.py` — every `rootBundle` asset is declared.
   - `tools/check_contrast.py` — every key fg/bg pair meets WCAG AA.
   - `tools/validate_data.py` — dataset integrity (dupes, numeral values).

The codebase has been through five audit-driven hardening passes (runtime,
bloc-lifecycle, performance, accessibility, code-health), each adversarially
verified before fixes landed.

## 8. `flutter analyze` policy

Errors and warnings fail CI; **info-level lints** (`prefer_const_constructors`,
`require_trailing_commas`, deprecations) are reported but non-blocking
(`--no-fatal-infos`). Run `dart fix --apply` + `dart format .` locally to clear
them and re-enable strict infos.

## 9. Known limitations

- **Text scaling:** clamped to ≤1.5×; full WCAG 200% needs each activity/
  selection screen made scrollable with intrinsic heights — best validated on a
  device.
- **Fonts** (`Inter`/`JetBrains Mono`/`Noto Sans`) are named but not bundled, so
  CJK/Cyrillic/Arabic render via the platform's system-font fallback.
- **Persistence backend** is `shared_preferences`; the SQLite/Hive path is
  designed (schema + interfaces) but not yet wired.

## 10. Directory tree (abridged)

```
lib/
├── main.dart                      # runZonedGuarded > MultiBlocProvider > MaterialApp > RootGate
├── core/{constants,theme,utils,data,widgets}/
└── features/
    ├── background/                # geometric backdrop
    ├── fact_engine/              # interstitial (isolate-offloaded decode)
    ├── language/                 # lexicon, SM-2, catalog, selection screen
    ├── math/                     # problem bank, MathBloc, domain matrix
    ├── sync_engine/              # DDC + interlocking injector
    ├── activity_engine/{polygon_polyglot,isometric_tessellation,matrix_vector_track}/
    ├── review/                   # SM-2 review session
    ├── progress/  streak/  achievements/   # persisted progress + derived state
    ├── settings/  onboarding/  about/      # settings, first-run gate, about
    └── home/                     # module selection + root gate
assets/data/                       # facts_seed.json, lexicon_seed.json
database/schema.sql                # full SQLite schema (future backend)
tools/                             # seed_* + validate_* + check_* (CI contracts)
test/                              # 27 files / 115 tests (unit + widget)
.github/workflows/flutter.yml      # CI: analyze, test, contracts, build-apk
```
