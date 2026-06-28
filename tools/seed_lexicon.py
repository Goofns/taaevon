#!/usr/bin/env python3
"""
Taaevon — Universal Lexicon seeding pipeline.

Validates and inserts language + word records into the SQLite lexicon tables.
Mirrors the contract guards in seed_facts.py: structure, enum whitelists,
non-empty translations, and a positive syllable count.

Usage:
    python tools/seed_lexicon.py <db_path> <lexicon_json_path>

Example:
    python tools/seed_lexicon.py assets/db/taaevon.db assets/data/lexicon_seed.json
"""

import json
import sqlite3
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List

VALID_LEXICAL = {"academic", "everyday", "slang", "technical", "formal"}
VALID_CEFR = {"A1", "A2", "B1", "B2", "C1", "C2"}
VALID_DIR = {"ltr", "rtl", "ttb"}

SCHEMA = """
CREATE TABLE IF NOT EXISTS languages (
    language_code TEXT PRIMARY KEY,
    language_name TEXT NOT NULL,
    native_name   TEXT NOT NULL,
    script_family TEXT,
    writing_dir   TEXT,
    has_tones     INTEGER DEFAULT 0,
    total_words   INTEGER,
    launch_tier   INTEGER
);
CREATE TABLE IF NOT EXISTS universal_lexicon (
    word_id          TEXT PRIMARY KEY,
    source_language  TEXT,
    target_language  TEXT,
    base_term        TEXT NOT NULL,
    translated_term  TEXT NOT NULL,
    phonetic_ipa     TEXT,
    romanization     TEXT,
    lexical_category TEXT NOT NULL,
    part_of_speech   TEXT,
    frequency_rank   INTEGER,
    cefr_level       TEXT,
    audio_asset_uri  TEXT,
    syllable_count   INTEGER,
    syllable_pattern TEXT,
    slang_context_notes TEXT,
    regional_variants   TEXT,
    example_sentence_source TEXT,
    example_sentence_target TEXT,
    math_extracted_value INTEGER,
    created_at       TEXT NOT NULL,
    updated_at       TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_lex_tgt  ON universal_lexicon(target_language);
CREATE INDEX IF NOT EXISTS idx_lex_cefr ON universal_lexicon(cefr_level);
"""


def validate_word(w: Dict) -> List[str]:
    errors: List[str] = []
    for field in ("source_language", "target_language", "base_term",
                  "translated_term", "lexical_category"):
        if not w.get(field):
            errors.append(f"missing {field}")
    if errors:
        return errors
    if w["lexical_category"] not in VALID_LEXICAL:
        errors.append(f"bad lexical_category: {w['lexical_category']!r}")
    if w.get("cefr_level") and w["cefr_level"] not in VALID_CEFR:
        errors.append(f"bad cefr_level: {w['cefr_level']!r}")
    if int(w.get("syllable_count", 0)) < 1:
        errors.append("syllable_count must be >= 1")
    return errors


def seed(db_path: str, payload: Dict) -> Dict:
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.executescript(SCHEMA)
    now = datetime.now(timezone.utc).isoformat()

    stats = {"languages": 0, "words": 0, "rejected": 0, "rejections": [],
             "by_pair": {}}

    with conn:
        for lang in payload.get("languages", []):
            if lang.get("writing_dir") and lang["writing_dir"] not in VALID_DIR:
                continue
            conn.execute(
                """INSERT OR REPLACE INTO languages
                   (language_code, language_name, native_name, script_family,
                    writing_dir, has_tones, launch_tier)
                   VALUES (?,?,?,?,?,?,?)""",
                (lang["language_code"], lang["language_name"],
                 lang["native_name"], lang.get("script_family"),
                 lang.get("writing_dir"), lang.get("has_tones", 0),
                 lang.get("launch_tier")),
            )
            stats["languages"] += 1

        for i, w in enumerate(payload.get("words", [])):
            errs = validate_word(w)
            if errs:
                stats["rejected"] += 1
                stats["rejections"].append((i, errs))
                continue
            conn.execute(
                """INSERT OR REPLACE INTO universal_lexicon
                   (word_id, source_language, target_language, base_term,
                    translated_term, phonetic_ipa, romanization,
                    lexical_category, part_of_speech, frequency_rank,
                    cefr_level, audio_asset_uri, syllable_count,
                    syllable_pattern, slang_context_notes, regional_variants,
                    example_sentence_source, example_sentence_target,
                    math_extracted_value, created_at, updated_at)
                   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                (
                    w.get("word_id") or str(uuid.uuid4()),
                    w["source_language"], w["target_language"], w["base_term"],
                    w["translated_term"], w.get("phonetic_ipa"),
                    w.get("romanization"), w["lexical_category"],
                    w.get("part_of_speech"), w.get("frequency_rank"),
                    w.get("cefr_level"), w.get("audio_asset_uri"),
                    w.get("syllable_count"), w.get("syllable_pattern"),
                    w.get("slang_context_notes"),
                    json.dumps(w.get("regional_variants", [])),
                    w.get("example_sentence_source"),
                    w.get("example_sentence_target"),
                    w.get("math_extracted_value"), now, now,
                ),
            )
            stats["words"] += 1
            pair = f"{w['source_language']}-{w['target_language']}"
            stats["by_pair"][pair] = stats["by_pair"].get(pair, 0) + 1

    conn.execute("VACUUM")
    conn.close()
    return stats


def report(stats: Dict) -> None:
    line = "=" * 56
    print(f"\n{line}\nTAAEVON LEXICON SEEDING REPORT\n{line}")
    print(f"Languages : {stats['languages']:>4}")
    print(f"Words     : {stats['words']:>4}")
    print(f"Rejected  : {stats['rejected']:>4}")
    print("\nBy language pair")
    for pair in sorted(stats["by_pair"]):
        print(f"  {pair:<10} {stats['by_pair'][pair]:>4}")
    for idx, errs in stats["rejections"]:
        print(f"  reject #{idx}: {'; '.join(errs)}")
    print(line)


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python tools/seed_lexicon.py <db_path> <lexicon_json>")
        return 1
    with open(sys.argv[2], "r", encoding="utf-8") as fh:
        payload = json.load(fh)
    report(seed(sys.argv[1], payload))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
