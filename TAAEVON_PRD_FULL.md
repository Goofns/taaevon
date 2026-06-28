# TAAEVON — Product Requirement Document & Technical Specification
## Version 1.0 | Classification: Production Blueprint | Date: 2026-06-04

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Product Vision & Strategic Goals](#2-product-vision--strategic-goals)
3. [Visual Identity & UI/UX Design System](#3-visual-identity--uiux-design-system)
4. [Cross-Platform Technical Architecture](#4-cross-platform-technical-architecture)
5. [Database Schema & Data Architecture](#5-database-schema--data-architecture)
6. [Micro-Learning Loading Engine](#6-micro-learning-loading-engine)
7. [Mathematics Curriculum Specification](#7-mathematics-curriculum-specification)
8. [Language & Lexicon Curriculum Specification](#8-language--lexicon-curriculum-specification)
9. [Gamified Activity Engine](#9-gamified-activity-engine)
10. [Concurrent Dual-Curriculum Syncing Logic](#10-concurrent-dual-curriculum-syncing-logic)
11. [Cross-Platform Compilation & Optimization](#11-cross-platform-compilation--optimization)
12. [Production Roadmap](#12-production-roadmap)
13. [Boilerplate Code Reference](#13-boilerplate-code-reference)
14. [Accessibility & Compliance](#14-accessibility--compliance)
15. [Appendix: Wireframe Concepts](#15-appendix-wireframe-concepts)

---

## 1. EXECUTIVE SUMMARY

**Product Name:** TAAEVON
**Category:** Cross-Platform Educational Application
**Target Platforms:** iOS (14.0+) and Android (API Level 26+)
**Framework:** Flutter 3.x (Dart)
**Primary Audiences:** Pre-K learners (age 3) through Post-Graduate Adults (age 30+)
**Core Value Proposition:** A single, unified application delivering mastery-level education across two fundamental cognitive domains — Mathematics and Language — simultaneously, with zero idle time through a micro-learning interstitial engine, all rendered in a distraction-free Abstract Geometric Minimalist visual framework.

**Key Differentiators:**
- Dual-curriculum synchronization: math and language modules are algorithmically interlocked, not siloed.
- Strict zero-character/mascot aesthetic eliminates demographic barriers and cognitive distraction.
- 10,000+ verified fact engine converts every loading state into a learning moment.
- Hardware-accelerated geometric rendering at 120Hz on ProMotion/high-refresh displays.
- Full offline functionality via local SQLite/Hive caching of core content.

---

## 2. PRODUCT VISION & STRATEGIC GOALS

### 2.1 Vision Statement
To build the world's most cognitively respectful educational platform — one that trusts every learner, regardless of age or starting point, with genuine knowledge and never wastes a single second of their attention.

### 2.2 Strategic Goals

| Goal | Metric | Target |
|------|--------|--------|
| Curriculum Coverage | Age cohorts supported | Pre-K through Post-Graduate (all tiers) |
| Language Coverage | Global languages supported at launch | 50+ languages |
| Fact Database | Verified facts in interstitial engine | 10,000 minimum at launch |
| Load-Time Perception | User-perceived wait time | < 50ms fact render on transition |
| Offline Capability | Core content accessible offline | 100% of Tier 1–3 curriculum |
| ADA Compliance | WCAG 2.1 AA conformance | Full conformance |
| Frame Rate | Geometric animation target | 120Hz on capable hardware, 60Hz fallback |
| Engagement Retention | D7 retention benchmark | ≥ 45% |

### 2.3 Non-Goals
- No social/community features in v1.0.
- No live tutoring or video content in v1.0.
- No character-based or mascot-driven engagement systems — ever (constitutional constraint).
- No AR/VR in v1.0 (reserved for v2.0 roadmap).

---

## 3. VISUAL IDENTITY & UI/UX DESIGN SYSTEM

### 3.1 Design Philosophy: Abstract Geometric Minimalism
The entire visual system is built on a single governing principle: **geometry is the universal language**. Every visual element communicates through shape, proportion, and spatial relationship — never through anthropomorphic representation.

### 3.2 Color Palette

#### Primary Background
```
Background Base:     #E6F0FA  (Faint Ice Blue — HSL 210°, 52%, 94%)
Background Alt:      #EDF4FB  (Lighter variant for card surfaces)
Background Deep:     #D4E6F5  (Deeper variant for pressed/active states)
```

#### Geometric Watermark Layer (Background Shapes)
```
Polygon Opacity:     8% – 12% maximum
Polygon Color:       #B8D4EC  (Muted slate blue)
Grid Line Color:     #C5DCF0  (Isometric grid strokes)
Grid Line Width:     0.5px
Grid Line Opacity:   15%
```

#### Foreground Interactive Palette
```
Primary Action:      #1A3C5E  (Deep Navy — 7.2:1 contrast on background)
Secondary Action:    #0D6EFD  (Electric Blue — 4.6:1 contrast, AA compliant)
Success State:       #0B6E4F  (Deep Emerald — 5.1:1 contrast)
Warning State:       #8B4000  (Burnt Sienna — 5.8:1 contrast)
Error/Reset State:   #7B1010  (Deep Crimson — 6.4:1 contrast)
Neutral Text:        #1C2B3A  (Near-black blue-tinted)
Secondary Text:      #3D5A6E  (Muted slate)
Disabled State:      #8FA6B5  (Low-contrast grey-blue)
```

#### Accent Geometry Palette (Interactive Elements Only)
```
Polygon Fill A:      #2D6A9F  (Medium Blue)
Polygon Fill B:      #1B5299  (Royal Blue)
Polygon Fill C:      #0E4D78  (Oxford Blue)
Polygon Fill D:      #3B82C4  (Sky Steel)
Polygon Stroke:      #FFFFFF  at 90% opacity
```

### 3.3 Typography

```
Display Font:        Inter (Variable) — Weight 700/800
Body Font:           Inter (Variable) — Weight 400/500
Monospace/Math:      JetBrains Mono — for equations, code, numerical displays
CJK/Script Support:  Noto Sans (full unicode coverage for all language modules)
Minimum Body Size:   16sp (Android) / 16pt (iOS) — never below
Math Equation Size:  18sp minimum — always rendered via MathRender engine
```

### 3.4 Geometric Background Layer Specification

The background layer is a **static, non-animated** geometric composition generated procedurally at app launch and cached. It consists of three stacked sublayers:

**Sublayer 1 — Isometric Grid:**
- 60° isometric line grid
- Line spacing: 48dp
- Stroke color: #C5DCF0 at 12% opacity
- Extends full viewport; no clipping at edges

**Sublayer 2 — Polygon Field:**
- 8–14 irregular convex polygons (5–8 vertices each)
- Sizes: 80dp to 320dp diameter
- Fill: #B8D4EC at 8–10% opacity
- No polygon overlaps center interactive zone (safe zone: central 60% of viewport)
- Positioned deterministically based on a seed derived from user ID hash (consistent per user, varied across users)

**Sublayer 3 — Depth Accent:**
- 3–5 large circles (200dp–600dp diameter)
- Fill: radial gradient from #B8D4EC (9% opacity center) to transparent
- Positioned at viewport corners and midpoints

**Constraint:** Background layer renders once. It does NOT animate, pulse, or respond to touch. Zero GPU load after initial render.

### 3.5 Component Design Specifications

#### Cards / Content Panels
```
Background:     #FFFFFF at 72% opacity (frosted effect)
Border:         1px solid #C5DCF0
Border Radius:  16dp
Shadow:         0 4dp 16dp rgba(26, 60, 94, 0.08)
Padding:        20dp horizontal, 16dp vertical
```

#### Primary Buttons
```
Background:     #1A3C5E
Text:           #FFFFFF, Inter 600, 16sp
Border Radius:  12dp
Height:         52dp
Padding:        24dp horizontal
Active State:   Scale 0.97, Background #0D3050
Disabled:       Background #8FA6B5, Text #FFFFFF
```

#### Input Fields
```
Background:     #FFFFFF at 90% opacity
Border:         1.5px solid #B8D4EC
Border Active:  1.5px solid #0D6EFD
Border Radius:  10dp
Height:         52dp
Text:           #1C2B3A, 16sp
Label:          #3D5A6E, 13sp, above field
```

#### Progress Indicators
```
Track Color:    #D4E6F5
Fill Color:     #1A3C5E (math) / #0D6EFD (language)
Height:         6dp
Border Radius:  3dp (pill shape)
Animation:      Spring physics, 350ms
```

#### Fact Interstitial Card
```
Background:     #1A3C5E (inverted for maximum contrast on transition)
Text:           #FFFFFF, Inter 400, 15sp
Category Badge: Rounded pill, #0D6EFD background
Icon:           Geometric polygon glyph (no emoji, no faces)
Padding:        24dp all sides
Animation:      Fade in 120ms, fade out 80ms
```

---

## 4. CROSS-PLATFORM TECHNICAL ARCHITECTURE

### 4.1 Framework Selection: Flutter 3.x

**Rationale:**
- Single Dart codebase compiles to native ARM binary on both iOS and Android.
- Skia/Impeller rendering engine provides identical pixel-level geometric rendering on all devices.
- Native 120Hz support via Flutter's `SchedulerBinding` high-frequency frame scheduling.
- First-class SQLite (via `sqflite`) and Hive integration for offline caching.
- BLoC state management integrates cleanly with Dart's stream architecture.

### 4.2 High-Level Architecture Diagram (Described)

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ Geometric    │  │ Curriculum   │  │ Interstitial      │  │
│  │ Background   │  │ Screen Stack │  │ Overlay Layer     │  │
│  │ Canvas       │  │ (Math/Lang)  │  │ (Fact Engine UI)  │  │
│  └──────────────┘  └──────────────┘  └───────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    STATE MANAGEMENT LAYER (BLoC)             │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐    │
│  │ Math BLoC   │  │ Language    │  │ Fact Engine BLoC │    │
│  │             │  │ BLoC        │  │ (Isolated)       │    │
│  └─────────────┘  └─────────────┘  └──────────────────┘    │
│  ┌─────────────┐  ┌─────────────┐                           │
│  │ DDC Engine  │  │ User        │                           │
│  │ BLoC        │  │ Progress    │                           │
│  │             │  │ BLoC        │                           │
│  └─────────────┘  └─────────────┘                           │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  ┌───────────────────┐  ┌──────────────────────────────┐    │
│  │ Curriculum        │  │ Synchronization Engine        │    │
│  │ Repository        │  │ (Interlocking Progression)    │    │
│  └───────────────────┘  └──────────────────────────────┘    │
│  ┌───────────────────┐  ┌──────────────────────────────┐    │
│  │ Fact Repository   │  │ Dynamic Difficulty Calibrator │    │
│  └───────────────────┘  └──────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐     │
│  │ SQLite/Hive  │  │ Remote API   │  │ Asset Bundle  │     │
│  │ Local Cache  │  │ (Sync/Update)│  │ (Audio/Fonts) │     │
│  └──────────────┘  └──────────────┘  └───────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Project Directory Structure

```
taaevon/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── colors.dart
│   │   │   ├── typography.dart
│   │   │   └── dimensions.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── utils/
│   │       ├── uuid_generator.dart
│   │       └── complexity_filter.dart
│   ├── features/
│   │   ├── background/
│   │   │   ├── geometric_background_painter.dart
│   │   │   └── background_seed_generator.dart
│   │   ├── fact_engine/
│   │   │   ├── bloc/
│   │   │   │   ├── fact_bloc.dart
│   │   │   │   ├── fact_event.dart
│   │   │   │   └── fact_state.dart
│   │   │   ├── data/
│   │   │   │   ├── fact_repository.dart
│   │   │   │   └── fact_local_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── fact_entity.dart
│   │   │   │   └── get_random_fact_usecase.dart
│   │   │   └── presentation/
│   │   │       └── fact_interstitial_widget.dart
│   │   ├── math/
│   │   │   ├── bloc/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   ├── language/
│   │   │   ├── bloc/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   ├── sync_engine/
│   │   │   ├── interlocking_progression.dart
│   │   │   └── dynamic_difficulty_calibrator.dart
│   │   └── activity_engine/
│   │       ├── polygon_polyglot/
│   │       ├── matrix_vector_track/
│   │       └── isometric_tessellation/
│   └── main.dart
├── assets/
│   ├── fonts/
│   ├── audio/
│   └── db/
│       └── facts_seed.db
├── test/
├── integration_test/
├── android/
├── ios/
└── pubspec.yaml
```

### 4.4 Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  # Local Database
  sqflite: ^2.3.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  # Navigation
  go_router: ^14.0.0
  # UUID
  uuid: ^4.4.0
  # Audio (Language pronunciation)
  just_audio: ^0.9.40
  # Math Rendering
  flutter_math_fork: ^0.7.2
  # Internationalization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  # HTTP (for content sync)
  dio: ^5.4.3
  # Secure Storage (user progress)
  flutter_secure_storage: ^9.2.2
  # Custom Fonts
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

---

## 5. DATABASE SCHEMA & DATA ARCHITECTURE

### 5.1 Fact Repository — NoSQL/JSON Document Structure

Each fact document conforms to the following schema. The database is seeded locally as a bundled SQLite file (`facts_seed.db`) and optionally updated via remote sync.

```json
{
  "fact_id": "UUID_v4",
  "category": "String",
  "subcategory": "String",
  "content": "String (max 280 chars, mobile-optimized)",
  "extended_content": "String (optional, full detail for expandable view)",
  "verification_source": "String (Academic URL or Citation)",
  "verification_type": "Enum: peer_reviewed | government | encyclopedia | institution",
  "complexity_rating": "Integer (1–5)",
  "age_group_flags": ["pre_k", "elementary", "middle", "high_school", "undergraduate", "graduate"],
  "language_neutral": "Boolean (true if no culturally specific context required)",
  "tags": ["Array of String keywords"],
  "curriculum_relevance": {
    "math_domains": ["Array: e.g., geometry, statistics, number_theory"],
    "language_concepts": ["Array: e.g., etymology, morphology, phonetics"]
  },
  "created_at": "ISO8601 Timestamp",
  "last_verified": "ISO8601 Timestamp"
}
```

#### Category Taxonomy (Minimum Distribution for 10,000 Facts)

| Category | Min Facts | Subcategories |
|----------|-----------|---------------|
| Mathematics & Logic | 800 | Number Theory, Geometry, Calculus, Statistics, Combinatorics, Set Theory, Topology |
| Linguistics & Language | 800 | Etymology, Phonetics, Morphology, Syntax, Pragmatics, Writing Systems |
| Physical Sciences | 1,200 | Physics, Chemistry, Astronomy, Thermodynamics, Quantum Mechanics |
| Life Sciences | 1,000 | Biology, Ecology, Genetics, Neuroscience, Marine Biology |
| Earth & Geosciences | 700 | Geology, Climatology, Oceanography, Hydrology |
| Geopolitics & Civics | 600 | International Relations, Governance, Economics, Demographics |
| History & Archaeology | 800 | Ancient Civilizations, Modern History, Cultural Anthropology |
| Technology & Engineering | 600 | Computer Science, Mechanical Engineering, Materials Science |
| Philosophy & Logic | 400 | Formal Logic, Ethics, Epistemology, Metaphysics |
| Arts & Architecture | 400 | Architectural Geometry, Music Theory, Visual Arts |
| Health & Medicine | 500 | Anatomy, Physiology, Public Health, Nutrition |
| Miscellaneous Global Facts | 1,200 | Cross-disciplinary, High-Interest, Trivia-Grade Verified Facts |
| **TOTAL** | **9,000 base** | *+1,000 reserved for dynamic expansion* |

### 5.2 SQLite Schema — Local Fact Storage

```sql
-- Facts table (offline-ready, locally bundled)
CREATE TABLE facts (
    fact_id          TEXT PRIMARY KEY,
    category         TEXT NOT NULL,
    subcategory      TEXT,
    content          TEXT NOT NULL,
    extended_content TEXT,
    verification_source TEXT,
    verification_type TEXT CHECK(verification_type IN
        ('peer_reviewed','government','encyclopedia','institution')),
    complexity_rating INTEGER NOT NULL CHECK(complexity_rating BETWEEN 1 AND 5),
    language_neutral  INTEGER NOT NULL DEFAULT 1,  -- 0=false, 1=true
    tags             TEXT,  -- JSON array stored as string
    math_domains     TEXT,  -- JSON array stored as string
    language_concepts TEXT, -- JSON array stored as string
    created_at       TEXT NOT NULL,
    last_verified    TEXT NOT NULL
);

CREATE INDEX idx_facts_category ON facts(category);
CREATE INDEX idx_facts_complexity ON facts(complexity_rating);
CREATE INDEX idx_facts_language_neutral ON facts(language_neutral);

-- Fact delivery tracking (prevents repeat delivery within session)
CREATE TABLE fact_session_delivery (
    session_id   TEXT NOT NULL,
    fact_id      TEXT NOT NULL,
    delivered_at TEXT NOT NULL,
    PRIMARY KEY (session_id, fact_id)
);
```

### 5.3 Universal Lexicon Schema — Full Relational Model

```sql
-- Languages registry
CREATE TABLE languages (
    language_code   VARCHAR(10) PRIMARY KEY,  -- ISO 639-1 + BCP 47
    language_name   VARCHAR(100) NOT NULL,
    native_name     VARCHAR(100) NOT NULL,
    script_family   VARCHAR(50),  -- Latin, Cyrillic, CJK, Arabic, Devanagari, etc.
    writing_dir     VARCHAR(3) CHECK(writing_dir IN ('ltr','rtl','ttb')),
    has_tones       INTEGER DEFAULT 0,
    total_words     INTEGER,
    launch_tier     INTEGER CHECK(launch_tier IN (1,2,3))
    -- Tier 1: 10 core languages at launch
    -- Tier 2: 20 additional languages in v1.1
    -- Tier 3: Remaining 20+ in v1.2+
);

-- Core universal lexicon
CREATE TABLE universal_lexicon (
    word_id           TEXT PRIMARY KEY,  -- UUID v4
    source_language   VARCHAR(10) REFERENCES languages(language_code),
    target_language   VARCHAR(10) REFERENCES languages(language_code),
    base_term         VARCHAR(255) NOT NULL,
    translated_term   VARCHAR(255) NOT NULL,
    phonetic_ipa      VARCHAR(255),  -- IPA notation for pronunciation
    romanization      VARCHAR(255),  -- For non-Latin scripts
    lexical_category  VARCHAR(20) NOT NULL
        CHECK(lexical_category IN ('academic','everyday','slang','technical','formal')),
    part_of_speech    VARCHAR(30),  -- noun, verb, adjective, etc.
    frequency_rank    INTEGER,  -- 1 = most frequent in language corpus
    cefr_level        VARCHAR(3) CHECK(cefr_level IN ('A1','A2','B1','B2','C1','C2')),
    audio_asset_uri   VARCHAR(512),
    syllable_count    INTEGER,
    syllable_pattern  VARCHAR(100),  -- e.g., "CV-CVC" phonological structure
    slang_context_notes TEXT,
    regional_variants TEXT,  -- JSON array of {region, variant_term}
    example_sentence_source TEXT,
    example_sentence_target TEXT,
    math_extracted_value INTEGER,  -- Syllabic/phonemic value for DDC engine
    created_at        TEXT NOT NULL,
    updated_at        TEXT NOT NULL
);

CREATE INDEX idx_lexicon_source_lang ON universal_lexicon(source_language);
CREATE INDEX idx_lexicon_target_lang ON universal_lexicon(target_language);
CREATE INDEX idx_lexicon_frequency ON universal_lexicon(frequency_rank);
CREATE INDEX idx_lexicon_cefr ON universal_lexicon(cefr_level);
CREATE INDEX idx_lexicon_category ON universal_lexicon(lexical_category);

-- Spaced repetition tracking per user per word
CREATE TABLE user_word_progress (
    user_id         TEXT NOT NULL,
    word_id         TEXT NOT NULL REFERENCES universal_lexicon(word_id),
    language_pair   VARCHAR(25) NOT NULL,  -- e.g., "en-ja"
    ease_factor     REAL NOT NULL DEFAULT 2.5,  -- SM-2 algorithm
    interval_days   INTEGER NOT NULL DEFAULT 1,
    repetitions     INTEGER NOT NULL DEFAULT 0,
    next_review     TEXT NOT NULL,  -- ISO8601
    last_reviewed   TEXT,
    mastery_level   INTEGER CHECK(mastery_level BETWEEN 0 AND 5),
    PRIMARY KEY (user_id, word_id)
);

-- Math curriculum content
CREATE TABLE math_curriculum (
    item_id         TEXT PRIMARY KEY,
    tier            INTEGER NOT NULL CHECK(tier BETWEEN 1 AND 3),
    domain          VARCHAR(50) NOT NULL,
    subdomain       VARCHAR(50),
    title           VARCHAR(255) NOT NULL,
    concept_latex   TEXT,  -- LaTeX for equation rendering
    concept_text    TEXT NOT NULL,
    difficulty      INTEGER CHECK(difficulty BETWEEN 1 AND 10),
    age_group_min   INTEGER,  -- minimum age recommendation
    prerequisite_ids TEXT,  -- JSON array of item_ids
    activity_type   VARCHAR(30),
    has_visual_component INTEGER DEFAULT 1
);

-- Language curriculum modules
CREATE TABLE language_modules (
    module_id       TEXT PRIMARY KEY,
    language_code   VARCHAR(10) REFERENCES languages(language_code),
    cefr_target     VARCHAR(3),
    module_name     VARCHAR(255) NOT NULL,
    module_type     VARCHAR(30) CHECK(module_type IN
        ('vocabulary','grammar','pronunciation','conversation','reading','writing')),
    lexical_category VARCHAR(20),
    word_count      INTEGER,
    estimated_minutes INTEGER,
    prerequisite_module_ids TEXT  -- JSON array
);

-- User progress (unified)
CREATE TABLE user_progress (
    user_id             TEXT NOT NULL,
    subject             VARCHAR(10) CHECK(subject IN ('math','language')),
    module_id           TEXT NOT NULL,
    completion_pct      REAL NOT NULL DEFAULT 0.0,
    mastery_score       REAL NOT NULL DEFAULT 0.0,
    last_activity       TEXT,
    total_time_seconds  INTEGER DEFAULT 0,
    PRIMARY KEY (user_id, subject, module_id)
);

-- Dynamic Difficulty Calibration telemetry
CREATE TABLE ddc_telemetry (
    record_id       TEXT PRIMARY KEY,
    user_id         TEXT NOT NULL,
    subject         VARCHAR(10) NOT NULL,
    session_id      TEXT NOT NULL,
    timestamp       TEXT NOT NULL,
    difficulty_level REAL NOT NULL,
    accuracy_rate   REAL NOT NULL,
    response_time_ms INTEGER NOT NULL,
    calibrated_level REAL NOT NULL
);
```

### 5.4 Hive Box Definitions (Hot-Path Cache)

For ultra-low-latency read access (< 5ms), frequently accessed data is mirrored to Hive:

```dart
// Hive box names
const String kFactCacheBox = 'fact_cache';       // ~500 pre-loaded facts in memory
const String kUserProgressBox = 'user_progress'; // current session progress
const String kDDCStateBox = 'ddc_state';         // live difficulty calibration state
const String kLexiconCacheBox = 'lexicon_cache'; // current module's vocabulary set
const String kSettingsBox = 'app_settings';      // theme, language prefs, etc.
```

---

## 6. MICRO-LEARNING LOADING ENGINE

### 6.1 Architecture Overview

The Fact Engine is architecturally **isolated** from all other BLoCs. It operates on its own stream, has its own Hive box, and communicates with the UI exclusively through an overlay layer — never blocking or being blocked by curriculum BLoCs.

### 6.2 Random-Access Algorithm

The algorithm guarantees:
1. No fact repeats within a session (tracked in `fact_session_delivery`).
2. Facts are filtered by the user's current age/complexity profile (derived from `ddc_state`).
3. Fact fetch + render latency target: < 50ms total.
4. Pre-loading: 50 facts pre-fetched into Hive on app launch for instant access.

```
Algorithm: InstantFactRetrieval

INPUT: user_complexity_level (1–5), session_delivered_ids (Set<String>)
OUTPUT: FactEntity

STEP 1: Query Hive fact_cache box
  - Filter where complexity_rating <= user_complexity_level
  - Filter where fact_id NOT IN session_delivered_ids
  - Select random index using crypto-secure PRNG

STEP 2: If Hive cache has < 10 remaining eligible facts:
  - Asynchronously refill cache from SQLite (non-blocking, background isolate)
  - Continue with available cache items

STEP 3: Mark selected fact_id in session_delivered_ids (in-memory Set)

STEP 4: Return FactEntity to UI overlay layer

TIMING CONTRACT:
  - Hive read:           < 2ms
  - PRNG selection:      < 1ms
  - Overlay mount:       < 20ms (Flutter frame budget)
  - Total perceived:     < 50ms ✓
```

### 6.3 Trigger Points

The Fact Engine overlay activates on the following events:

| Trigger | Duration | Dismissal |
|---------|----------|-----------|
| Screen navigation transition | Auto (matches route transition duration) | Auto-dismiss |
| API/network request | While request is pending | Auto-dismiss on complete |
| Database query > 200ms | While query is executing | Auto-dismiss on complete |
| Activity level load | Activity asset loading | Auto-dismiss |
| User-initiated "Learn More" | Persistent until user swipes | Manual swipe-to-dismiss |

### 6.4 Fact BLoC Implementation

```dart
// fact_event.dart
abstract class FactEvent extends Equatable {
  const FactEvent();
}

class FactRequested extends FactEvent {
  final int complexityLevel;
  const FactRequested({required this.complexityLevel});
  @override
  List<Object> get props => [complexityLevel];
}

class FactPrefetchRequested extends FactEvent {
  const FactPrefetchRequested();
  @override
  List<Object> get props => [];
}

// fact_state.dart
abstract class FactState extends Equatable {
  const FactState();
}

class FactInitial extends FactState {
  @override List<Object> get props => [];
}

class FactReady extends FactState {
  final FactEntity fact;
  const FactReady({required this.fact});
  @override List<Object> get props => [fact];
}

class FactError extends FactState {
  @override List<Object> get props => [];
}

// fact_bloc.dart
class FactBloc extends Bloc<FactEvent, FactState> {
  final GetRandomFactUseCase _getRandomFact;
  final Set<String> _deliveredIds = {};

  FactBloc({required GetRandomFactUseCase getRandomFact})
      : _getRandomFact = getRandomFact,
        super(const FactInitial()) {
    on<FactRequested>(_onFactRequested);
    on<FactPrefetchRequested>(_onPrefetchRequested);
  }

  Future<void> _onFactRequested(
    FactRequested event,
    Emitter<FactState> emit,
  ) async {
    final result = await _getRandomFact(
      complexityLevel: event.complexityLevel,
      excludeIds: _deliveredIds,
    );
    result.fold(
      (failure) => emit(const FactError()),
      (fact) {
        _deliveredIds.add(fact.factId);
        emit(FactReady(fact: fact));
      },
    );
  }

  Future<void> _onPrefetchRequested(
    FactPrefetchRequested event,
    Emitter<FactState> emit,
  ) async {
    // Background prefill — does not change state, purely cache operation
    await _getRandomFact.prefetchToCache(count: 50);
  }
}
```

---

## 7. MATHEMATICS CURRICULUM SPECIFICATION

### 7.1 Tier Architecture

The mathematics track is organized into three primary tiers and nine progression bands:

```
TIER 1 — FOUNDATIONAL (Ages 3–10)
├── Band 1A: Numeracy & Counting (Pre-K, Ages 3–5)
│   ├── Number recognition 1–20
│   ├── Counting sequences (forward, backward)
│   ├── One-to-one correspondence
│   ├── Shape recognition (circle, square, triangle, rectangle)
│   └── Basic spatial reasoning (above/below, inside/outside)
├── Band 1B: Elementary Arithmetic (K–Grade 2, Ages 5–8)
│   ├── Addition and subtraction within 100
│   ├── Place value (ones, tens, hundreds)
│   ├── Introduction to measurement
│   └── Basic data interpretation (simple bar graphs)
└── Band 1C: Operational Fluency (Grade 3–5, Ages 8–11)
    ├── Multiplication tables (1–12)
    ├── Long division
    ├── Introduction to fractions (½, ¼, ⅓)
    ├── Decimal notation
    └── Perimeter and area of basic shapes

TIER 2 — INTERMEDIATE (Ages 11–18)
├── Band 2A: Pre-Algebra & Introductory Algebra (Grades 6–8)
│   ├── Variables and expressions
│   ├── Linear equations (single variable)
│   ├── Ratios, proportions, percentages
│   ├── Integer operations
│   └── Coordinate plane fundamentals
├── Band 2B: Algebra I & Geometry (Grades 9–10)
│   ├── Systems of linear equations
│   ├── Quadratic functions and equations
│   ├── Euclidean geometry (proofs, theorems)
│   ├── Trigonometric ratios (SOH-CAH-TOA)
│   └── Basic probability and statistics
└── Band 2C: Pre-Calculus & Advanced Algebra (Grades 11–12)
    ├── Exponential and logarithmic functions
    ├── Sequences and series
    ├── Polar coordinates and vectors
    ├── Advanced trigonometry (unit circle, identities)
    └── Limits and continuity (pre-calculus introduction)

TIER 3 — ADVANCED (Ages 18+)
├── Band 3A: Calculus (Undergraduate)
│   ├── Differential calculus (derivatives, chain rule, implicit differentiation)
│   ├── Integral calculus (Riemann sums, fundamental theorem)
│   ├── Multivariable calculus (partial derivatives, gradients)
│   └── Vector calculus (curl, divergence, line integrals)
├── Band 3B: Linear Algebra & Discrete Mathematics
│   ├── Matrix operations, determinants, eigenvalues
│   ├── Vector spaces, linear transformations
│   ├── Graph theory, combinatorics, recurrence relations
│   └── Boolean algebra, propositional logic
└── Band 3C: Advanced Theoretical Mathematics (Post-Graduate)
    ├── Differential equations (ODEs, PDEs, Laplace transforms)
    ├── Abstract algebra (groups, rings, fields, Galois theory)
    ├── Real and complex analysis
    ├── Topology (metric spaces, homeomorphisms, manifolds)
    ├── Number theory (modular arithmetic, prime distribution)
    └── Category theory (functors, natural transformations)
```

### 7.2 Domain Selection Matrix UI

The Mathematics home screen presents a **selection matrix** rendered as a geometric grid:

- Each domain occupies a hexagonal or rectangular tile on an isometric grid.
- Tile color depth indicates completion percentage (lighter = less complete, darker = more complete).
- Locked tiles render at 30% opacity with a geometric lock glyph (no padlock character — a simple nested-square pattern).
- Tapping a tile navigates to the domain's activity menu.
- No linear path forced — users can select any unlocked domain freely.

### 7.3 Activity Types per Domain

| Domain | Primary Activity | Secondary Activity |
|--------|-----------------|-------------------|
| Numeracy | Geometric counting (tap polygon vertices) | Number line navigation |
| Arithmetic | Equation completion tiles | Isometric Tessellation game |
| Algebra | Variable slider puzzles | Matrix Vector Track |
| Geometry | Shape decomposition | Tessellation building |
| Trigonometry | Unit circle rotation | Vector direction puzzles |
| Calculus | Area-under-curve estimation | Differential equation tile fills |
| Linear Algebra | Matrix transformation visualizer | Vector maze (Matrix Vector Track) |
| Discrete Math | Graph coloring | Truth table tile puzzles |
| Abstract Math | Proof construction sequences | Category diagram mapping |

---

## 8. LANGUAGE & LEXICON CURRICULUM SPECIFICATION

### 8.1 Language Tiers at Launch

**Tier 1 Launch Languages (10 core):**
English, Spanish, Mandarin Chinese, Hindi, French, Arabic, Portuguese, Russian, Japanese, German

**Tier 2 (v1.1 — 20 additional):**
Korean, Italian, Dutch, Swedish, Turkish, Polish, Swahili, Tagalog, Bengali, Thai,
Vietnamese, Indonesian, Hebrew, Greek, Farsi/Persian, Ukrainian, Romanian, Czech, Hungarian, Norwegian

**Tier 3 (v1.2+ — 20+ additional):**
All remaining globally significant languages including regional variants, indigenous languages with sufficient digital corpus, and constructed languages (Latin, Classical Arabic) for academic modules.

### 8.2 Proficiency Ladder (CEFR-Aligned)

```
A0: Absolute Zero — Zero prior exposure. First 100 words. Phonetics only.
A1: Beginner     — 500 most-frequent words. Basic greetings, numbers, colors.
A2: Elementary   — 1,500 words. Simple sentences, present tense, survival phrases.
B1: Intermediate — 3,500 words. Past/future tense, opinions, narratives.
B2: Upper-Inter  — 6,000 words. Fluent conversation, academic reading.
C1: Advanced     — 10,000 words. Near-native, idiomatic, professional contexts.
C2: Mastery      — 15,000+ words. Full idiomatic command, literary register.
```

### 8.3 Vocabulary Lexical Categories

```
ACADEMIC: University-level discourse, technical terminology, formal writing.
  Examples: "hypothesis", "legislation", "phenomenon", "substantiate"

EVERYDAY: High-frequency conversational words (Zipf frequency rank 1–3000).
  Examples: "water", "where", "tomorrow", "understand", "please"

SLANG/COLLOQUIAL: Region-specific informal registers (tagged by region code).
  Examples: "bloke" (en-GB), "mate" (en-AU), "wicked" (en-US-NE), "guay" (es-MX)

TECHNICAL: Domain-specific vocabulary (science, medicine, law, computing).
  Examples: "photosynthesis", "jurisprudence", "algorithm", "mitosis"

FORMAL: High-register written language, diplomatic register.
  Examples: "heretofore", "pursuant to", "notwithstanding", "aforementioned"
```

### 8.4 Activity Engine for Language

#### Core Mechanics

1. **Geometric Flash Cards:** Word-to-translation pairs displayed on geometric tiles. User taps the correct translated tile within a field of 4–6 options. Wrong answers animate a tile edge "break" (geometric fragmentation). Correct answers complete a polygon vertex.

2. **Spaced Repetition Scheduler (SM-2 Algorithm):**
   ```
   E' = E + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
   where:
     E  = ease factor (min 1.3)
     q  = quality of recall (0–5 scale)
     E' = new ease factor
   
   If q < 3: reset interval to 1 day, reset repetitions
   If q ≥ 3: 
     Repetition 1: interval = 1 day
     Repetition 2: interval = 6 days
     Repetition n: interval = interval(n-1) × E
   ```

3. **Phonetic Tracing:** For scripts like Hiragana, Katakana, Hangul, Arabic — user traces the character along a glowing geometric path. The path is formed by connected line segments and arcs (purely geometric, no decorative elements).

4. **Syntax Pattern Matching:** Sentence-level exercises where word-order slots are represented as labeled geometric positions on a horizontal axis. User drags word-tiles into the correct positional geometry.

5. **Listening Discrimination:** Audio plays a word; four geometric tiles each show a different word. User selects the matching tile. Pure phonemic discrimination.

### 8.5 Audio Asset Architecture

```
Audio Format:  OGG Vorbis (Android primary), M4A/AAC (iOS primary)
Sample Rate:   22050 Hz
Channels:      Mono
Bit Rate:      48 kbps (vocabulary), 96 kbps (full sentence audio)
Storage:       Bundled for Tier 1 core 500 words per language (offline)
               Streaming/download for extended vocabulary
Naming:        {language_code}_{word_id}_{speed: normal|slow}.ogg
```

---

## 9. GAMIFIED ACTIVITY ENGINE

### 9.1 Core Design Constraint
All engagement mechanics must operate within the **zero-character / zero-face** constitutional constraint. Every piece of game logic is expressed through geometric transformation, spatial reasoning, and abstract shape interaction.

### 9.2 Activity: The Polygon Polyglot

**Learning Objectives:** Vocabulary retention, translation accuracy, progressive construction feedback.

**Mechanic:**
1. Screen presents an incomplete polygon (e.g., a hexagon with 4 of 6 vertices placed).
2. A phrase in the source language appears in the center.
3. Six geometric tiles radiate from the polygon, each containing a potential translation.
4. Selecting the correct translation animates the next vertex into place (spring physics, 350ms).
5. Incorrect selection causes the polygon to ripple/distort and resets the current vertex attempt.
6. Completing all vertices causes the polygon to fill with a gradient and settle into the background layer (permanently adding to the user's geometric "canvas").

**Geometric State Machine:**
```
State: POLYGON_INCOMPLETE
  → User selects CORRECT translation
    → State: VERTEX_ADDING (animation 350ms)
      → If all vertices placed: State: POLYGON_COMPLETE (celebration geometry: radiating lines, 500ms)
      → Else: State: POLYGON_INCOMPLETE (next word)
  → User selects INCORRECT translation
    → State: POLYGON_DISTORT (ripple animation 200ms)
    → Immediate return to: State: POLYGON_INCOMPLETE (same word, reshuffled options)
```

**Difficulty Scaling:**
- A0–A1: 4-vertex polygons (quadrilateral), 4 translation options, 20s time limit
- A2–B1: 5-vertex polygons, 6 options, 15s time limit
- B2–C1: 7-vertex polygons, 8 options, 10s time limit, distractors include near-homophones
- C2: Irregular 9-vertex polygons, 10 options, no time limit, includes idiomatic and slang options

### 9.3 Activity: The Matrix Vector Track

**Learning Objectives:** Spatial mathematics, coordinate systems, vocabulary association, number-concept linking.

**Mechanic:**
1. A 2D grid (initially 5×5, scaling to 10×10 at advanced levels) is displayed on the geometric canvas.
2. A vector arrow originates from a starting coordinate.
3. The user must navigate the vector to a target coordinate using directional controls (purely geometric: arrow-shaped polygons, no text labels on controls).
4. At each grid intersection, a vocabulary word appears in the target language. The numerical value of the coordinate (derived from the `math_extracted_value` field in the lexicon) must match the user's vector calculation.
5. Wrong coordinate: vector bounces back with a geometric recoil animation.
6. Correct final position: grid cell fills with an isometric tile pattern.

**DDC Integration:**
- If user's math level is Band 2B+: grid uses matrix transformation coordinates (not simple addition).
- If user's language level is A0: coordinate labels are shown in target script alongside romanization.
- If user is post-graduate math / A0 language: coordinates are expressed in the target language's number system (e.g., Chinese 三十七 for 37) to simultaneously teach math and language.

**Grid Coordinate Formula (Advanced Mode):**
```
Target = A·v
where A = 2×2 transformation matrix (from current math module)
      v = user-input direction vector
The user must compute A·v mentally to navigate correctly.
```

### 9.4 Activity: Isometric Tessellation

**Learning Objectives:** Equation solving, pattern recognition, mathematical beauty appreciation.

**Mechanic:**
1. An isometric grid is displayed on the canvas (the same faded background grid, now interactive).
2. A mathematical problem (arithmetic through calculus depending on level) appears above the grid.
3. Solving the problem correctly earns a geometric tile (equilateral triangle, rhombus, or hexagon).
4. The earned tile must be placed to continue a tessellation pattern without gaps or overlaps.
5. Valid placement: tile snaps with a haptic pulse and emits geometric radiating lines.
6. Invalid placement: tile bounces with a brief shake animation.
7. Completing a full tessellation panel (a defined N×N section) unlocks the next difficulty level.

**Tile Earning Matrix:**

| Problem Difficulty | Tile Type | Tile Points |
|-------------------|-----------|-------------|
| Band 1A–1B | Equilateral Triangle (simplest) | 1 |
| Band 1C–2A | Right Triangle | 2 |
| Band 2B–2C | Parallelogram | 3 |
| Band 3A | Hexagon | 5 |
| Band 3B–3C | Irregular Polygon (custom) | 8 |

### 9.5 Engagement Loop Architecture

```
SESSION START
     │
     ▼
DDC Assessment (if new user or > 7 days gap)
     │
     ▼
Module Selection Screen (Math domain grid OR Language CEFR ladder)
     │
     ├──► Math Path:  Select Domain → Select Activity → Execute Activity
     │                    ↑                                    │
     │                    └────────── Next Item Loop ◄─────────┘
     │
     └──► Language Path: Select Language → Select Module → Execute Activity
                              ↑                                 │
                              └──────── Spaced Rep Queue ◄──────┘
     
     [Any screen transition or load > 200ms]
          │
          ▼
     Fact Interstitial Overlay (< 50ms, non-blocking)
          │
          ▼
     Resume Activity
     
SESSION END
     │
     ▼
Progress sync to SQLite
     │
     ▼
DDC recalibration (background)
     │
     ▼
Next Session Date calculated (spaced rep for language)
```

---

## 10. CONCURRENT DUAL-CURRICULUM SYNCING LOGIC

### 10.1 Interlocking Progression System

The synchronization engine runs as a background Dart isolate, consuming events from both the Math BLoC and Language BLoC event streams. It produces `SyncInjectionEvents` that modify the active module's content.

```dart
// sync_engine/interlocking_progression.dart

class InterlockingProgressionEngine {
  final MathBlocStream mathStream;
  final LanguageBlocStream langStream;
  final DDCState ddcState;

  // Called when a language module activity completes
  SyncInjection extractMathDataFromLanguageCompletion(
    LanguageActivityResult result,
  ) {
    final word = result.lastWord;
    
    return SyncInjection(
      syllableCount: word.syllableCount,
      syllablePattern: word.syllablePattern,  // e.g., "CVC-CV"
      wordLength: word.baseTermLength,
      phonemeCount: word.phonemeCount,
      mathExtractedValue: word.mathExtractedValue,  // pre-computed in lexicon
      targetMathDomain: ddcState.currentMathDomain,
    );
  }

  // Injects language data as math variable context
  MathProblem injectLanguageDataIntoMathProblem({
    required MathProblemTemplate template,
    required SyncInjection injection,
  }) {
    // Replace symbolic variables with language-derived values
    // e.g., template: "Solve: f(x) = ax² + bx + c"
    // injection: a=syllableCount, b=wordLength, c=phonemeCount
    return template.instantiate(
      variableBindings: {
        'a': injection.syllableCount.toDouble(),
        'b': injection.wordLength.toDouble(),
        'c': injection.phonemeCount.toDouble(),
      },
      variableLabels: {
        // Display variable names using target language characters
        'a': injection.targetLanguageLabel('a'),
        'b': injection.targetLanguageLabel('b'),
        'c': injection.targetLanguageLabel('c'),
      },
    );
  }
}
```

### 10.2 Dynamic Difficulty Calibration (DDC) Engine

The DDC engine maintains **independent telemetry pipelines** for Math and Language, combining them only at the content injection layer.

```
DDC STATE SCHEMA
{
  user_id: String,
  math: {
    current_band: Float,       // e.g., 2.7 = between Band 2B and 2C
    accuracy_trailing_10: Float, // accuracy over last 10 items
    avg_response_ms: Integer,
    calibrated_difficulty: Float,
    domain_overrides: { domain_id: Float }  // per-domain fine-tuning
  },
  language: {
    active_language: String,
    current_cefr: String,
    per_language: {
      language_code: {
        cefr_level: String,
        accuracy_trailing_10: Float,
        avg_response_ms: Integer
      }
    }
  },
  cross_domain_injection_mode: Enum [
    MATH_INSTRUCTS_LANGUAGE,   // Math variable labels use target language
    LANGUAGE_SEEDS_MATH,       // Language word data becomes math variable values
    PARALLEL_INDEPENDENT,      // No injection, modules run independently
    FULL_INTERLOCK             // Both directions simultaneously
  ]
}
```

**DDC Algorithm — Difficulty Step Function:**

```
GIVEN: accuracy_trailing_10 (A), avg_response_ms (R), target_response_ms (T)

response_efficiency = T / R  (>1.0 = faster than target = easier than needed)
accuracy_factor = A          (0.0 to 1.0)

performance_score = (0.7 × accuracy_factor) + (0.3 × min(response_efficiency, 1.0))

IF performance_score > 0.85:
    difficulty += 0.1  (step up)
ELIF performance_score < 0.60:
    difficulty -= 0.15  (step down faster to prevent frustration)
ELSE:
    difficulty unchanged  (optimal zone: 0.60–0.85)

difficulty = clamp(difficulty, band_floor, band_ceiling)
```

**Cross-Domain Injection Decision Matrix:**

| Math Level | Language Level | Injection Mode |
|------------|---------------|----------------|
| Any | Same as Math | PARALLEL_INDEPENDENT |
| Band 3A+ | A0–A1 | FULL_INTERLOCK: Calculus vars in target script |
| Band 1A–1B | B2–C2 | LANGUAGE_SEEDS_MATH: Word data seeds arithmetic |
| Band 2A–2C | A2–B1 | MATH_INSTRUCTS_LANGUAGE: Equations use target language numbers |
| Band 3B–3C | B1–C2 | FULL_INTERLOCK: Abstract algebra with target language notation |

### 10.3 Concrete Example — Post-Graduate Math / A0 Japanese

**Scenario:** User is Band 3C (Topology) and has just started Japanese (A0).

**Standard topology problem (unmodified):**
> "Prove that the function f: ℝ → ℝ defined by f(x) = x² is continuous at x₀ = 3 using the ε-δ definition."

**DDC-Modified version (with Hiragana injection):**
> "つぎの かんすう (next function) ε-δ で ぞくせい (continuity) を しょうめい (prove) してください:"
> f(x) = x² — at point x₀ = さん (3)
> Find δ such that: |f(x) - f(さん)| < ε whenever |x - さん| < δ

**Effect:** The user encounters 6–8 Hiragana/Katakana characters and their romaji readings (さん = san = 3) while working through a problem at their true cognitive level. The Japanese vocabulary is inserted at points where mathematical context makes meaning inferrable.

---

## 11. CROSS-PLATFORM COMPILATION & OPTIMIZATION

### 11.1 Graphics Pipeline

**Flutter Impeller (default on iOS 15+ and Android API 29+):**
- Pre-compiles all geometric shaders at build time (eliminates shader compilation jank).
- Hardware-accelerated canvas operations for all `CustomPainter` geometric draws.
- Background canvas renders once per session using `RepaintBoundary` — isolated from repaints.

**120Hz / ProMotion Optimization:**
```dart
// main.dart — Request high refresh rate
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request 120Hz on capable hardware
  await FlutterDisplayMode.setHighRefreshRate();
  
  runApp(const TaaevonApp());
}
```

**Background Layer Caching Strategy:**
```dart
class GeometricBackgroundPainter extends CustomPainter {
  // Backed by a Picture cache — repaints never triggered by business logic
  // Only repaints on screen orientation change
  @override
  bool shouldRepaint(GeometricBackgroundPainter oldDelegate) => false;
}
```

### 11.2 State Management — Strict Unidirectional Flow

```
User Action
    │
    ▼
UI Widget dispatches Event to BLoC
    │
    ▼
BLoC UseCase calls Repository
    │
    ▼
Repository reads/writes Data Source (Hive or SQLite)
    │
    ▼
Repository returns Either<Failure, Entity>
    │
    ▼
BLoC emits new State
    │
    ▼
UI Widget rebuilds via BlocBuilder (minimal, targeted rebuilds)
```

**BLoC Separation Guarantee:** The `FactBloc` is provided at the root `MaterialApp` level and shares zero state with `MathBloc` or `LanguageBloc`. They communicate only through the `InterlockingProgressionEngine` which acts as a pure function transformer — no shared mutable state.

### 11.3 Offline Architecture

**Initial App Bundle (Offline-Ready at Install):**
```
facts_seed.db          — All 10,000+ facts (estimated ~8 MB compressed)
lexicon_tier1_core.db  — Top 500 words × 10 Tier 1 languages (estimated ~15 MB)
math_curriculum_t1.db  — Full Tier 1 math curriculum content (estimated ~4 MB)
Total offline bundle:  ~30 MB (within acceptable app size bounds)
```

**Progressive Download (Background Sync):**
```
On first WiFi connection after install:
  → Download full Tier 2 lexicon (~80 MB)
  → Download Tier 2 and 3 math content (~20 MB)
  → Download audio assets for active languages (~5 MB per language)
```

**Conflict Resolution:** Device-local data always wins. Remote sync only appends (no overwrites of local progress data).

### 11.4 Performance Benchmarks

| Operation | Target | Implementation |
|-----------|--------|----------------|
| App cold start | < 2.5s | Lazy BLoC init, Hive opens on first use |
| Screen transition | < 300ms | GoRouter + custom page transition (no default slide) |
| Fact retrieval | < 50ms | Hive pre-cache, PRNG selection |
| Math problem render | < 100ms | flutter_math_fork cached LaTeX |
| Audio playback start | < 150ms | just_audio pre-buffering for active module |
| SQLite query (lexicon) | < 80ms | Indexed queries, Hive hot-cache for current module |
| Background DB sync | Non-blocking | Dart isolate, never touches main isolate |

---

## 12. PRODUCTION ROADMAP

### Phase 1: Foundation & Data (Weeks 1–12)

**Goal:** Complete data infrastructure. App can load, display facts, and show curriculum structure with no content yet.

| Sprint | Deliverables |
|--------|-------------|
| S1–S2 | Flutter project scaffold, design system tokens, GeometricBackgroundPainter |
| S3–S4 | SQLite schema creation, Hive box definitions, database migration system |
| S5–S6 | **Fact seeding pipeline**: Python script to ingest, verify, and insert 10,000 facts into `facts_seed.db` with source citations |
| S7–S8 | Fact BLoC + GetRandomFactUseCase + FactInterstitialWidget (fully functional) |
| S9–S10 | Core Tier 1 lexicon seeding for 10 languages (top 500 words each, with audio URIs) |
| S11–S12 | Universal lexicon schema populated, SM-2 spaced repetition engine unit-tested |

**Phase 1 Exit Criteria:**
- [ ] 10,000 facts in database, all with valid complexity ratings and categories
- [ ] Fact interstitial renders in < 50ms (measured, not estimated)
- [ ] Tier 1 lexicon: 5,000 word entries with IPA and syllable counts
- [ ] All database queries under load pass performance benchmarks
- [ ] SQLite bundled as app asset, offline access verified

**Fact Seeding Script (Python — Phase 1 Reference):**

```python
#!/usr/bin/env python3
# seed_facts.py — Phase 1 fact database seeding pipeline

import sqlite3
import uuid
import json
from datetime import datetime, timezone
from typing import List, Dict
import re

COMPLEXITY_THRESHOLDS = {
    1: "pre_k elementary",
    2: "middle",
    3: "high_school",
    4: "undergraduate",
    5: "graduate postgraduate"
}

REQUIRED_CATEGORIES = [
    "Mathematics & Logic", "Linguistics & Language", "Physical Sciences",
    "Life Sciences", "Earth & Geosciences", "Geopolitics & Civics",
    "History & Archaeology", "Technology & Engineering",
    "Philosophy & Logic", "Arts & Architecture", "Health & Medicine",
    "Miscellaneous Global Facts"
]

def validate_fact(fact: Dict) -> bool:
    """Validate a fact entry before insertion."""
    required_fields = ['content', 'category', 'complexity_rating',
                       'verification_source', 'verification_type']
    
    for field in required_fields:
        if field not in fact or not fact[field]:
            return False
    
    if not (1 <= fact['complexity_rating'] <= 5):
        return False
    
    if len(fact['content']) > 280:
        return False
    
    if fact['category'] not in REQUIRED_CATEGORIES:
        return False
    
    # Basic source URL validation
    source = fact['verification_source']
    if not (source.startswith('http') or source.startswith('ISBN') 
            or source.startswith('DOI')):
        return False
    
    return True

def insert_fact(conn: sqlite3.Connection, fact: Dict) -> str:
    """Insert a single validated fact. Returns fact_id."""
    fact_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()
    
    conn.execute("""
        INSERT INTO facts (
            fact_id, category, subcategory, content, extended_content,
            verification_source, verification_type, complexity_rating,
            language_neutral, tags, math_domains, language_concepts,
            created_at, last_verified
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        fact_id,
        fact['category'],
        fact.get('subcategory', ''),
        fact['content'],
        fact.get('extended_content', ''),
        fact['verification_source'],
        fact['verification_type'],
        fact['complexity_rating'],
        1 if fact.get('language_neutral', True) else 0,
        json.dumps(fact.get('tags', [])),
        json.dumps(fact.get('math_domains', [])),
        json.dumps(fact.get('language_concepts', [])),
        now,
        fact.get('last_verified', now)
    ))
    return fact_id

def seed_database(db_path: str, facts: List[Dict]) -> Dict:
    """Seed the facts database. Returns summary statistics."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    
    stats = {
        'total_attempted': len(facts),
        'inserted': 0,
        'rejected': 0,
        'by_category': {},
        'by_complexity': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
    }
    
    with conn:
        for fact in facts:
            if validate_fact(fact):
                fact_id = insert_fact(conn, fact)
                stats['inserted'] += 1
                cat = fact['category']
                stats['by_category'][cat] = stats['by_category'].get(cat, 0) + 1
                stats['by_complexity'][fact['complexity_rating']] += 1
            else:
                stats['rejected'] += 1
    
    conn.close()
    return stats

def build_fact_cache_index(db_path: str):
    """Create optimized lookup indexes after seeding."""
    conn = sqlite3.connect(db_path)
    with conn:
        conn.execute("ANALYZE facts")
        conn.execute("VACUUM")
    conn.close()
    print("Database optimized (ANALYZE + VACUUM complete)")

def generate_distribution_report(stats: Dict):
    """Print distribution report after seeding."""
    print(f"\n{'='*50}")
    print(f"FACT DATABASE SEEDING REPORT")
    print(f"{'='*50}")
    print(f"Total attempted:  {stats['total_attempted']:,}")
    print(f"Successfully inserted: {stats['inserted']:,}")
    print(f"Rejected (invalid):   {stats['rejected']:,}")
    print(f"\nBy Category:")
    for cat, count in sorted(stats['by_category'].items()):
        print(f"  {cat:<35} {count:>5}")
    print(f"\nBy Complexity Level:")
    for level, count in stats['by_complexity'].items():
        label = COMPLEXITY_THRESHOLDS[level]
        print(f"  Level {level} ({label:<20}) {count:>5}")

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print("Usage: python seed_facts.py <db_path> <facts_json_path>")
        sys.exit(1)
    
    db_path = sys.argv[1]
    facts_path = sys.argv[2]
    
    with open(facts_path, 'r', encoding='utf-8') as f:
        facts = json.load(f)
    
    stats = seed_database(db_path, facts)
    build_fact_cache_index(db_path)
    generate_distribution_report(stats)
```

---

### Phase 2: UI Styling Engine & Geometric Design System (Weeks 10–20)

**Goal:** Full visual system implemented. Every screen matches design spec. Background layer, all component styles, all activity canvases complete.

| Sprint | Deliverables |
|--------|-------------|
| S10–S11 | Design token system (colors.dart, typography.dart, dimensions.dart) |
| S12–S13 | GeometricBackgroundPainter: isometric grid + polygon field + depth accents |
| S14–S15 | Core widget library: Card, Button, Input, ProgressBar, Badge, FactCard |
| S16–S17 | Math domain selection matrix screen (hexagonal tile grid) |
| S17–S18 | Language CEFR ladder screen and language selector |
| S19–S20 | Polygon Polyglot activity canvas (full geometric state machine) |
| S20 | Matrix Vector Track canvas |
| S20 | Isometric Tessellation canvas |

**Phase 2 Exit Criteria:**
- [ ] All screens pixel-match design specification (reviewed in both iOS Simulator and Android Emulator)
- [ ] Background layer renders in < 16ms (one frame budget)
- [ ] All interactive elements pass WCAG 2.1 AA contrast check
- [ ] Geometric animations run at 60Hz minimum (120Hz on capable devices)
- [ ] Zero character/mascot/face assets in the entire asset bundle (audited)

**Boilerplate: Geometric Background Layer (Flutter):**

```dart
// features/background/geometric_background_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeometricBackgroundPainter extends CustomPainter {
  final int seedValue;

  const GeometricBackgroundPainter({required this.seedValue});

  @override
  void paint(Canvas canvas, Size size) {
    _drawIsometricGrid(canvas, size);
    _drawPolygonField(canvas, size);
    _drawDepthAccents(canvas, size);
  }

  void _drawIsometricGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5DCF0).withOpacity(0.12)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 48.0;
    const angleRad = math.pi / 3; // 60 degrees

    // Horizontal lines
    for (double y = 0; y < size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 60-degree lines (left-leaning)
    final tanAngle = math.tan(angleRad);
    for (double x = -size.height / tanAngle; x < size.width; x += spacing) {
      final startX = x;
      final endX = x + size.height / tanAngle;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, size.height),
        paint,
      );
    }

    // 120-degree lines (right-leaning)
    for (double x = 0; x < size.width + size.height / tanAngle; x += spacing) {
      final startX = x;
      final endX = x - size.height / tanAngle;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, size.height),
        paint,
      );
    }
  }

  void _drawPolygonField(Canvas canvas, Size size) {
    final rng = math.Random(seedValue);
    final paint = Paint()
      ..color = const Color(0xFFB8D4EC).withOpacity(0.09)
      ..style = PaintingStyle.fill;

    final polygonCount = 8 + rng.nextInt(7); // 8–14 polygons

    for (int i = 0; i < polygonCount; i++) {
      final centerX = rng.nextDouble() * size.width;
      final centerY = rng.nextDouble() * size.height;

      // Skip if center is within the safe zone (central 60%)
      final safeZoneX = size.width * 0.20;
      final safeZoneY = size.height * 0.20;
      final safeW = size.width * 0.60;
      final safeH = size.height * 0.60;
      if (centerX > safeZoneX && centerX < safeZoneX + safeW &&
          centerY > safeZoneY && centerY < safeZoneY + safeH) {
        continue;
      }

      final radius = 40.0 + rng.nextDouble() * 140.0; // 40–180dp
      final vertexCount = 5 + rng.nextInt(4); // 5–8 vertices

      final path = Path();
      for (int v = 0; v < vertexCount; v++) {
        final angle = (2 * math.pi * v / vertexCount) - math.pi / 2;
        final jitter = 0.7 + rng.nextDouble() * 0.6;
        final x = centerX + radius * jitter * math.cos(angle);
        final y = centerY + radius * jitter * math.sin(angle);
        if (v == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawDepthAccents(Canvas canvas, Size size) {
    final rng = math.Random(seedValue + 1);
    final accentPositions = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
      Offset(size.width / 2, size.height / 2),
    ];

    for (int i = 0; i < 3 + rng.nextInt(3); i++) {
      final pos = accentPositions[i % accentPositions.length];
      final radius = 100.0 + rng.nextDouble() * 200.0;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFB8D4EC).withOpacity(0.09),
            const Color(0xFFB8D4EC).withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: radius));

      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(GeometricBackgroundPainter oldDelegate) =>
      oldDelegate.seedValue != seedValue;
}

// Usage widget
class GeometricBackground extends StatelessWidget {
  final int seed;
  final Widget child;

  const GeometricBackground({
    super.key,
    required this.seed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer — never repaints
        RepaintBoundary(
          child: CustomPaint(
            painter: GeometricBackgroundPainter(seedValue: seed),
            child: const SizedBox.expand(),
          ),
        ),
        // Content layer
        child,
      ],
    );
  }
}
```

---

### Phase 3: Curriculum Mapping & Full Integration (Weeks 18–32)

**Goal:** All curriculum tiers implemented, DDC engine live, dual-curriculum sync operational, full offline functionality.

| Sprint | Deliverables |
|--------|-------------|
| S18–S20 | Math Tier 1 full content, activities, and SM-2 logic |
| S20–S22 | Language Tier 1 content for 10 languages, Polygon Polyglot fully integrated |
| S22–S24 | DDC engine: telemetry pipeline, calibration algorithm, state management |
| S24–S26 | Interlocking Progression Engine: cross-domain injection operational |
| S26–S28 | Math Tiers 2–3 content and activities |
| S28–S30 | Language Tier 2 (20 additional languages), Matrix Vector Track integrated |
| S30–S31 | Full offline bundle optimization, SQLite VACUUM and index tuning |
| S31–S32 | Beta testing, performance profiling, ADA audit, 120Hz verification |

**Phase 3 Exit Criteria:**
- [ ] All 3 math tiers and 9 bands have ≥ 20 problems per difficulty level
- [ ] All 10 Tier 1 languages have ≥ 500 words with audio
- [ ] DDC recalibration cycle runs in < 500ms in background isolate
- [ ] Cross-domain injection produces syntactically valid problems 100% of the time
- [ ] Full app works without network connection (verified with airplane mode testing)
- [ ] App passes WCAG 2.1 AA audit
- [ ] Frame rate ≥ 60Hz on test devices with 4GB RAM minimum

---

## 13. BOILERPLATE CODE REFERENCE

### 13.1 Design Tokens

```dart
// core/constants/colors.dart

import 'package:flutter/material.dart';

abstract class TaaevonColors {
  // Background palette
  static const Color backgroundBase = Color(0xFFE6F0FA);
  static const Color backgroundAlt = Color(0xFFEDF4FB);
  static const Color backgroundDeep = Color(0xFFD4E6F5);

  // Geometric watermark layer
  static const Color polygonFill = Color(0xFFB8D4EC);
  static const Color gridLine = Color(0xFFC5DCF0);

  // Foreground interactive
  static const Color primaryAction = Color(0xFF1A3C5E);
  static const Color secondaryAction = Color(0xFF0D6EFD);
  static const Color success = Color(0xFF0B6E4F);
  static const Color warning = Color(0xFF8B4000);
  static const Color error = Color(0xFF7B1010);
  static const Color neutralText = Color(0xFF1C2B3A);
  static const Color secondaryText = Color(0xFF3D5A6E);
  static const Color disabled = Color(0xFF8FA6B5);

  // Accent geometry (interactive elements)
  static const Color accentA = Color(0xFF2D6A9F);
  static const Color accentB = Color(0xFF1B5299);
  static const Color accentC = Color(0xFF0E4D78);
  static const Color accentD = Color(0xFF3B82C4);

  // Math track accent
  static const Color mathAccent = Color(0xFF1A3C5E);
  // Language track accent
  static const Color languageAccent = Color(0xFF0D6EFD);

  // Fact interstitial
  static const Color factBackground = Color(0xFF1A3C5E);
  static const Color factText = Color(0xFFFFFFFF);
  static const Color factBadge = Color(0xFF0D6EFD);

  // Surface
  static const Color cardBackground = Color(0x78FFFFFF); // 47% opacity white
  static const Color cardBorder = Color(0xFFC5DCF0);
  static const Color inputBackground = Color(0xE6FFFFFF); // 90% opacity
  static const Color inputBorder = Color(0xFFB8D4EC);
  static const Color inputBorderActive = Color(0xFF0D6EFD);
}
```

```dart
// core/constants/typography.dart

import 'package:flutter/material.dart';

abstract class TaaevonTypography {
  static const String fontFamilyDisplay = 'Inter';
  static const String fontFamilyBody = 'Inter';
  static const String fontFamilyMono = 'JetBrainsMono';
  static const String fontFamilyUniversal = 'NotoSans';

  static const double minBodySize = 16.0;
  static const double minMathSize = 18.0;

  static TextStyle display(BuildContext context) => TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: TaaevonColors.neutralText,
    letterSpacing: -0.5,
  );

  static TextStyle heading(BuildContext context) => TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: TaaevonColors.neutralText,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: TaaevonColors.neutralText,
    height: 1.5,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: TaaevonColors.secondaryText,
    letterSpacing: 0.2,
  );

  static TextStyle mono(BuildContext context) => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: TaaevonColors.neutralText,
  );

  static TextStyle factCard(BuildContext context) => TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: TaaevonColors.factText,
    height: 1.6,
  );
}
```

### 13.2 Random Fact Retrieval — Core Use Case

```dart
// features/fact_engine/domain/get_random_fact_usecase.dart

import 'dart:math';
import 'package:dartz/dartz.dart';
import '../data/fact_repository.dart';
import 'fact_entity.dart';

class GetRandomFactUseCase {
  final FactRepository _repository;
  final Random _rng = Random.secure();

  GetRandomFactUseCase({required FactRepository repository})
      : _repository = repository;

  Future<Either<FactFailure, FactEntity>> call({
    required int complexityLevel,
    required Set<String> excludeIds,
  }) async {
    final stopwatch = Stopwatch()..start();

    // STEP 1: Try Hive cache first (target: < 5ms)
    final cached = await _repository.getCachedFacts(
      complexityMax: complexityLevel,
      excludeIds: excludeIds,
    );

    if (cached.isNotEmpty) {
      final selected = cached[_rng.nextInt(cached.length)];
      stopwatch.stop();
      assert(stopwatch.elapsedMilliseconds < 50,
          'PERF WARNING: Fact retrieval took ${stopwatch.elapsedMilliseconds}ms');
      return Right(selected);
    }

    // STEP 2: Fallback to SQLite (target: < 45ms)
    final result = await _repository.getRandomFactFromDb(
      complexityMax: complexityLevel,
      excludeIds: excludeIds,
      limit: 50,
    );

    return result.fold(
      (failure) => Left(failure),
      (facts) {
        if (facts.isEmpty) return Left(FactFailure.exhausted);
        final selected = facts[_rng.nextInt(facts.length)];
        // Async refill cache — fire and forget
        _repository.refillCache(facts: facts);
        stopwatch.stop();
        return Right(selected);
      },
    );
  }

  Future<void> prefetchToCache({required int count}) async {
    await _repository.prefetchFacts(count: count);
  }
}

enum FactFailure { exhausted, databaseError, cacheError }
```

### 13.3 Fact Interstitial Widget

```dart
// features/fact_engine/presentation/fact_interstitial_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/fact_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class FactInterstitialOverlay extends StatelessWidget {
  final int complexityLevel;

  const FactInterstitialOverlay({
    super.key,
    required this.complexityLevel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<FactBloc>()
        ..add(FactRequested(complexityLevel: complexityLevel)),
      child: BlocBuilder<FactBloc, FactState>(
        builder: (context, state) {
          if (state is! FactReady) {
            return const SizedBox.shrink();
          }
          return _FactCard(fact: state.fact);
        },
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final dynamic fact;

  const _FactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TaaevonColors.factBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TaaevonColors.primaryAction.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: TaaevonColors.factBadge,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                fact.category.toUpperCase(),
                style: TextStyle(
                  fontFamily: TaaevonTypography.fontFamilyBody,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Fact content
            Text(
              fact.content,
              style: TaaevonTypography.factCard(context),
            ),
            const SizedBox(height: 16),
            // Complexity indicator (geometric dots, not stars)
            Row(
              children: List.generate(5, (i) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i < fact.complexityRating
                      ? TaaevonColors.factBadge
                      : Colors.white24,
                  shape: BoxShape.circle,
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 14. ACCESSIBILITY & COMPLIANCE

### 14.1 WCAG 2.1 AA Requirements

| Criterion | Requirement | Implementation |
|-----------|------------|----------------|
| 1.4.3 Contrast (Minimum) | 4.5:1 normal text | All text colors verified ✓ |
| 1.4.4 Resize Text | 200% without loss | Flutter text scaling respected ✓ |
| 1.4.11 Non-text Contrast | 3:1 for UI components | All buttons/inputs verified ✓ |
| 2.1.1 Keyboard | All functionality via keyboard | Flutter Shortcuts + Focus nodes ✓ |
| 2.4.3 Focus Order | Logical tab order | Explicit `FocusTraversalGroup` ✓ |
| 2.5.3 Label in Name | Touch targets ≥ 44×44dp | All interactive elements ✓ |
| 3.1.1 Language of Page | Language identified | `Locale` set per module ✓ |
| 4.1.2 Name, Role, Value | Semantic widgets | Flutter `Semantics` widgets ✓ |

### 14.2 Screen Reader Support

All geometric elements that convey meaning must have `Semantics` labels:

```dart
Semantics(
  label: 'Polygon progress: 3 of 6 vertices completed',
  child: PolygonProgressWidget(completed: 3, total: 6),
)
```

### 14.3 Motor Accessibility

- All gesture targets: minimum 44×44dp (meets Apple HIG and Material guidelines).
- No time-limited activities at level A0–A1 (accommodates motor/cognitive differences).
- Time limits at B1+ are configurable in settings (1.5× and 2× time extensions).
- Drag interactions (Tessellation) have tap-to-select alternative mode.

---

## 15. APPENDIX: WIREFRAME CONCEPTS

### Screen 1: Home / Module Selection

```
┌─────────────────────────────────────┐
│ ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·   │ ← Isometric grid (12% opacity)
│         ╱◇╲        ◇               │
│     ◇ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─         │ ← Polygon field (9% opacity)
│ ·  ╲_╱  ·  ·  ·  ·  ·  ·  ·  ·   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │                             │   │
│   │    T A A E V O N            │   │ ← Display font, 32pt
│   │                             │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌──────────────┐ ┌─────────────┐  │
│   │   ╱╲  ╱╲    │ │  ─────────  │  │
│   │  ╱  ╲╱  ╲   │ │  ABC   123  │  │
│   │  ╲  ╱╲  ╱   │ │  ─────────  │  │
│   │   ╲╱  ╲╱    │ │             │  │
│   │  MATHEMATICS │ │  LANGUAGE   │  │
│   └──────────────┘ └─────────────┘  │
│                                     │
│   [Your Progress ──────────── 37%]  │ ← Progress bar
│   [Daily Goal   ────── ○       ]    │
│                                     │
└─────────────────────────────────────┘
```

### Screen 2: Mathematics Domain Selection Matrix

```
┌─────────────────────────────────────┐
│  ← Back     MATHEMATICS             │
├─────────────────────────────────────┤
│                                     │
│  TIER 1: FOUNDATIONAL               │
│  ┌───────┐ ┌───────┐ ┌───────┐     │
│  │ ████  │ │ ████  │ │ ░░░░  │     │ ← Darker = more complete
│  │Counting│ │Arithm │ │Fracs  │     │
│  └───────┘ └───────┘ └───────┘     │
│                                     │
│  TIER 2: INTERMEDIATE               │
│  ┌───────┐ ┌───────┐ ┌───────┐     │
│  │ ██░░  │ │ ░░░░  │ │ ░░░░  │     │
│  │Algebra │ │Geomet │ │PreCalc│     │
│  └───────┘ └───────┘ └───────┘     │
│                                     │
│  TIER 3: ADVANCED   [LOCKED ░░░░]  │
│  ┌───────┐ ┌───────┐ ┌───────┐     │
│  │ ▓▓▓▓  │ │ ▓▓▓▓  │ │ ▓▓▓▓  │     │ ← Locked tiles
│  │Calculus│ │LinAlg │ │Abstract     │
│  └───────┘ └───────┘ └───────┘     │
│                                     │
└─────────────────────────────────────┘
```

### Screen 3: Polygon Polyglot Activity

```
┌─────────────────────────────────────┐
│  ✕         POLYGON POLYGLOT         │
│  ─────────────────────────────────  │
│  Translate: "Thank you"  → Japanese │
│                                     │
│         ●───────────●               │
│        ╱             ╲             │ ← Incomplete hexagon
│       ●               ╳            │   ╳ = missing vertex
│        ╲             ╱             │
│         ●───────────●               │
│            [3/6 ██░░░░]            │ ← Vertex progress
│                                     │
│  ┌──────────┐  ┌──────────┐        │
│  │ ありがとう │  │  こんにちは│        │ ← Option tiles
│  │ Arigatou  │  │ Konnichiwa│        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │  さようなら │  │  すみません│        │
│  │Sayounara  │  │ Sumimasen │        │
│  └──────────┘  └──────────┘        │
│                                     │
│        [12s remaining ████░]        │ ← Geometric timer bar
└─────────────────────────────────────┘
```

### Screen 4: Fact Interstitial (Loading State)

```
┌─────────────────────────────────────┐
│                                     │
│  ╔═════════════════════════════╗    │
│  ║  [QUANTUM PHYSICS]          ║    │ ← Category badge (navy BG)
│  ║                             ║    │
│  ║  A single photon of light   ║    │
│  ║  passing through a double   ║    │
│  ║  slit simultaneously        ║    │
│  ║  interferes with itself,    ║    │
│  ║  demonstrating the wave-    ║    │
│  ║  particle duality of matter ║    │
│  ║  at quantum scales.         ║    │
│  ║                             ║    │
│  ║  ● ● ● ○ ○  COMPLEXITY 3   ║    │ ← Dot complexity indicator
│  ╚═════════════════════════════╝    │
│                                     │
│         Loading your lesson...      │ ← Below card, subtle text
│            ●  ●  ●                  │ ← Geometric loading dots
└─────────────────────────────────────┘
```

### Screen 5: DDC Cross-Domain Injection (Post-Grad Math / A0 Japanese)

```
┌─────────────────────────────────────┐
│  TOPOLOGY — CONTINUITY PROOF        │
│  Math Level: 9.2 | Japanese: A0     │
├─────────────────────────────────────┤
│                                     │
│  Prove using ε-δ definition:        │
│                                     │
│  ┌────────────────────────────────┐ │
│  │  f(x) = x²  at  x₀ = さん (3) │ │ ← さん = san = 3
│  │                                │ │
│  │  Find δ such that:             │ │
│  │                                │ │
│  │  |f(x) - f(さん)| < ε          │ │
│  │                                │ │
│  │  whenever |x - さん| < δ        │ │
│  └────────────────────────────────┘ │
│                                     │
│  New word: さん = san = three (3)   │ ← Vocabulary surface
│  [さん ♪]  [Repeat ↺]  [Got it ✓]  │
│                                     │
│  [Write proof ──────────────────]  │
└─────────────────────────────────────┘
```

---

*TAAEVON PRD v1.0 — End of Document*
*Total sections: 15 | Total specifications: Cross-platform, Dual-curriculum, 10,000+ facts, 50+ languages*
*Next revision trigger: Phase 1 completion (database seeding milestone)*
