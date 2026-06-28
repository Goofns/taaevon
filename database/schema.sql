-- ============================================================================
-- TAAEVON — Local SQLite Schema (v1.0)
-- Bundled as assets/db/taaevon.db for offline-first operation.
-- Apply with:  sqlite3 taaevon.db < database/schema.sql
-- ============================================================================

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- MICRO-LEARNING FACT ENGINE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS facts (
    fact_id             TEXT PRIMARY KEY,
    category            TEXT NOT NULL,
    subcategory         TEXT,
    content             TEXT NOT NULL,
    extended_content    TEXT,
    verification_source TEXT NOT NULL,
    verification_type   TEXT NOT NULL
        CHECK(verification_type IN
            ('peer_reviewed','government','encyclopedia','institution')),
    complexity_rating   INTEGER NOT NULL CHECK(complexity_rating BETWEEN 1 AND 5),
    language_neutral    INTEGER NOT NULL DEFAULT 1,  -- 0=false, 1=true
    tags                TEXT,  -- JSON array stored as string
    math_domains        TEXT,  -- JSON array
    language_concepts   TEXT,  -- JSON array
    created_at          TEXT NOT NULL,
    last_verified       TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_facts_category   ON facts(category);
CREATE INDEX IF NOT EXISTS idx_facts_complexity ON facts(complexity_rating);
CREATE INDEX IF NOT EXISTS idx_facts_neutral    ON facts(language_neutral);

CREATE TABLE IF NOT EXISTS fact_session_delivery (
    session_id   TEXT NOT NULL,
    fact_id      TEXT NOT NULL,
    delivered_at TEXT NOT NULL,
    PRIMARY KEY (session_id, fact_id)
);

-- ----------------------------------------------------------------------------
-- LANGUAGE TRACK — UNIVERSAL LEXICON
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS languages (
    language_code  TEXT PRIMARY KEY,            -- ISO 639-1 / BCP 47
    language_name  TEXT NOT NULL,
    native_name    TEXT NOT NULL,
    script_family  TEXT,
    writing_dir    TEXT CHECK(writing_dir IN ('ltr','rtl','ttb')),
    has_tones      INTEGER DEFAULT 0,
    total_words    INTEGER,
    launch_tier    INTEGER CHECK(launch_tier IN (1,2,3))
);

CREATE TABLE IF NOT EXISTS universal_lexicon (
    word_id              TEXT PRIMARY KEY,
    source_language      TEXT REFERENCES languages(language_code),
    target_language      TEXT REFERENCES languages(language_code),
    base_term            TEXT NOT NULL,
    translated_term      TEXT NOT NULL,
    phonetic_ipa         TEXT,
    romanization         TEXT,
    lexical_category     TEXT NOT NULL
        CHECK(lexical_category IN
            ('academic','everyday','slang','technical','formal')),
    part_of_speech       TEXT,
    frequency_rank       INTEGER,
    cefr_level           TEXT CHECK(cefr_level IN ('A1','A2','B1','B2','C1','C2')),
    audio_asset_uri      TEXT,
    syllable_count       INTEGER,
    syllable_pattern     TEXT,
    slang_context_notes  TEXT,
    regional_variants    TEXT,  -- JSON array
    example_sentence_source TEXT,
    example_sentence_target TEXT,
    math_extracted_value INTEGER,  -- feeds the DDC cross-domain injector
    created_at           TEXT NOT NULL,
    updated_at           TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_lex_src   ON universal_lexicon(source_language);
CREATE INDEX IF NOT EXISTS idx_lex_tgt   ON universal_lexicon(target_language);
CREATE INDEX IF NOT EXISTS idx_lex_freq  ON universal_lexicon(frequency_rank);
CREATE INDEX IF NOT EXISTS idx_lex_cefr  ON universal_lexicon(cefr_level);
CREATE INDEX IF NOT EXISTS idx_lex_cat   ON universal_lexicon(lexical_category);

CREATE TABLE IF NOT EXISTS user_word_progress (
    user_id       TEXT NOT NULL,
    word_id       TEXT NOT NULL REFERENCES universal_lexicon(word_id),
    language_pair TEXT NOT NULL,
    ease_factor   REAL NOT NULL DEFAULT 2.5,   -- SM-2
    interval_days INTEGER NOT NULL DEFAULT 1,
    repetitions   INTEGER NOT NULL DEFAULT 0,
    next_review   TEXT NOT NULL,
    last_reviewed TEXT,
    mastery_level INTEGER CHECK(mastery_level BETWEEN 0 AND 5),
    PRIMARY KEY (user_id, word_id)
);

-- ----------------------------------------------------------------------------
-- MATH TRACK
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS math_curriculum (
    item_id          TEXT PRIMARY KEY,
    tier             INTEGER NOT NULL CHECK(tier BETWEEN 1 AND 3),
    domain           TEXT NOT NULL,
    subdomain        TEXT,
    title            TEXT NOT NULL,
    concept_latex    TEXT,
    concept_text     TEXT NOT NULL,
    difficulty       INTEGER CHECK(difficulty BETWEEN 1 AND 10),
    age_group_min    INTEGER,
    prerequisite_ids TEXT,  -- JSON array
    activity_type    TEXT,
    has_visual_component INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS language_modules (
    module_id        TEXT PRIMARY KEY,
    language_code    TEXT REFERENCES languages(language_code),
    cefr_target      TEXT,
    module_name      TEXT NOT NULL,
    module_type      TEXT CHECK(module_type IN
        ('vocabulary','grammar','pronunciation','conversation','reading','writing')),
    lexical_category TEXT,
    word_count       INTEGER,
    estimated_minutes INTEGER,
    prerequisite_module_ids TEXT  -- JSON array
);

-- ----------------------------------------------------------------------------
-- UNIFIED PROGRESS + DYNAMIC DIFFICULTY CALIBRATION
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_progress (
    user_id            TEXT NOT NULL,
    subject            TEXT CHECK(subject IN ('math','language')),
    module_id          TEXT NOT NULL,
    completion_pct     REAL NOT NULL DEFAULT 0.0,
    mastery_score      REAL NOT NULL DEFAULT 0.0,
    last_activity      TEXT,
    total_time_seconds INTEGER DEFAULT 0,
    PRIMARY KEY (user_id, subject, module_id)
);

CREATE TABLE IF NOT EXISTS ddc_telemetry (
    record_id        TEXT PRIMARY KEY,
    user_id          TEXT NOT NULL,
    subject          TEXT NOT NULL,
    session_id       TEXT NOT NULL,
    timestamp        TEXT NOT NULL,
    difficulty_level REAL NOT NULL,
    accuracy_rate    REAL NOT NULL,
    response_time_ms INTEGER NOT NULL,
    calibrated_level REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_ddc_user ON ddc_telemetry(user_id, subject);
