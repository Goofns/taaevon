# Taaevon — Architecture

This document maps the codebase so a new contributor can navigate it quickly.
It reflects what is actually in `lib/` and `test/` today (71 Dart files, 17 test
suites). For product scope see [TAAEVON_PRD_FULL.md](TAAEVON_PRD_FULL.md); for
how to run it see [README.md](README.md).

## 1. Layering

Each feature follows a light Clean-Architecture split:

```
presentation/   Flutter widgets, CustomPainters, screens (no business logic)
bloc/ | cubit/  flutter_bloc — events in, states out, unidirectional
domain/         pure entities + rules (no Flutter imports) — the testable core
data/           datasources + repositories (assets now; SQLite/Hive later)
```

The **pure `domain/` layer is where the logic lives and where the tests aim** —
it has no Flutter dependency, so its rules (SM-2, DDC, placement, navigation)
are verifiable in isolation and were cross-checked against Python oracles.

## 2. Feature map (`lib/features/`)

| Feature | Responsibility | Key files |
|---------|----------------|-----------|
| `background/` | Static geometric backdrop (iso grid + polygon field), deterministic per user | `geometric_background_painter.dart`, `background_seed_generator.dart` |
| `fact_engine/` | Micro-learning interstitial; isolated BLoC, <50ms retrieval | `bloc/fact_bloc.dart`, `domain/get_random_fact_usecase.dart` |
| `language/` | Universal lexicon entity, SM-2 scheduler, language catalog + picker | `domain/spaced_repetition.dart`, `domain/language_catalog.dart` |
| `math/` | Problem bank (arithmetic→calculus), live problem BLoC, domain matrix | `domain/math_problem_bank.dart`, `bloc/math_bloc.dart` |
| `sync_engine/` | **Signature feature**: DDC step function + cross-domain injector | `dynamic_difficulty_calibrator.dart`, `interlocking_progression.dart` |
| `activity_engine/polygon_polyglot/` | Vertex-locking translation game | `bloc/polyglot_bloc.dart` |
| `activity_engine/isometric_tessellation/` | Solve-to-earn-tile board game | `domain/tessellation_board.dart`, `bloc/tessellation_bloc.dart` |
| `activity_engine/matrix_vector_track/` | Vector grid navigation + number-words | `domain/vector_track.dart`, `bloc/vector_track_bloc.dart` |
| `progress/` | Session-scoped completion tracking, surfaced on home | `cubit/progress_cubit.dart` |
| `home/` | Module selection, track cards, daily-goal bar | `presentation/home_screen.dart` |

## 3. State management

- **Unidirectional flow** via `flutter_bloc`. UI dispatches events; BLoCs emit
  states; `BlocBuilder`/`BlocConsumer` rebuild.
- **`FactBloc` is isolated** — it shares no mutable state with curriculum BLoCs
  (PRD §11.2). Activities likewise own their own BLoC, provided at the screen.
- **`ProgressCubit` is provided above `MaterialApp`** (`main.dart`) so every
  pushed route can record completions and `home` can read them. Activities call
  `recordCompletion(...)` from a `BlocConsumer.listener` on their `Complete`
  transition.
- Dart-3 **sealed states + exhaustive `switch` expressions** drive the screens.

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
accuracy back into `DynamicDifficultyCalibrator.calibrate` to move the band.
The marquee path (band 3.0 + CEFR A1 → `fullInterlock`) renders post-grad math
with beginner-script number-words.

## 5. Data layer & offline strategy

- **Now (runnable with zero native setup):** datasources load bundled JSON
  (`assets/data/facts_seed.json`, `assets/data/lexicon_seed.json`) into memory.
- **Production (PRD §11.3):** swap to `sqflite` over the bundled
  `taaevon.db` (schema in `database/schema.sql`), fronted by a Hive hot-cache.
  The repository interfaces are unchanged across the swap.
- **Seeding pipelines** (`tools/seed_facts.py`, `tools/seed_lexicon.py`) validate
  every record (structure, enum whitelists, source format, length, complexity)
  before insert. They are the path each record takes toward the 10,000-fact goal.

## 6. Testing & verification strategy

Because no Flutter SDK is assumed on every machine, verification is layered:

1. **Unit tests** (`test/`) assert the `domain/` rules and BLoC flows.
2. **Python oracles** independently confirm the numeric/algorithmic cores
   (SM-2 intervals, DDC step function, placement adjacency, vector navigation,
   injector substitution) — the Dart mirrors those exact values.
3. **Structural audit** (`scratchpad/audit_dart.py` pattern) checks delimiter
   balance, import resolution, and `part`/`part of` consistency across all files.
4. **CI** (`.github/workflows/flutter.yml`) runs `flutter analyze` + `flutter
   test` + dataset validation on every push — the type-level check that closes
   the remaining gap.

## 7. Known SDK-dependent gaps

- The codebase is structurally audited but **not yet compiled** here; `flutter
  analyze` is the authoritative next check.
- Real disk persistence (SQLite/Hive) and progress hydration are designed
  (interfaces + schema) but not wired — they need the SDK to verify.
- Fact interstitial currently fires on a manual trigger; hooking it to route
  transitions (PRD §6.3) is pending.

## 8. Directory tree (abridged)

```
lib/
├── main.dart                      # ProgressCubit > MaterialApp > FactBloc > Home
├── core/{constants,theme}/        # design tokens, ThemeData
└── features/
    ├── background/                # geometric backdrop
    ├── fact_engine/               # interstitial (bloc/data/domain/presentation)
    ├── language/                  # lexicon, SM-2, catalog, selection screen
    ├── math/                      # problem bank, MathBloc, domain matrix
    ├── sync_engine/               # DDC + interlocking injector
    ├── activity_engine/
    │   ├── polygon_polyglot/
    │   ├── isometric_tessellation/
    │   └── matrix_vector_track/
    ├── progress/                  # ProgressCubit
    └── home/
assets/data/                       # facts_seed.json, lexicon_seed.json
database/schema.sql                # full SQLite schema
tools/                             # seed_facts.py, seed_lexicon.py
test/                              # 17 suites (domain rules + BLoC flows)
.github/workflows/flutter.yml      # CI
```
