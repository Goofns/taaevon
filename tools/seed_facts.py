#!/usr/bin/env python3
"""
Taaevon — Phase 1 fact-database seeding pipeline.

Reads a JSON array of fact documents, validates each against the schema and the
"100% factually accurate" contract guards we *can* enforce automatically
(structure, length, category whitelist, source format, complexity bounds), then
inserts the survivors into a SQLite database.

Usage:
    python tools/seed_facts.py <db_path> <facts_json_path>

Example:
    python tools/seed_facts.py assets/db/taaevon.db assets/data/facts_seed.json

Note on the 10,000-fact target: this script is the *pipeline*. The bundled
facts_seed.json is a curated, genuinely-verifiable starter set. Reaching 10,000
is a content-operations effort — each fact passes through this validator plus a
human/source verification pass (see VERIFICATION.md workflow) before shipping.
"""

import json
import sqlite3
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List

# ---------------------------------------------------------------------------
# Contract constants
# ---------------------------------------------------------------------------
REQUIRED_CATEGORIES = {
    "Mathematics & Logic", "Linguistics & Language", "Physical Sciences",
    "Life Sciences", "Earth & Geosciences", "Geopolitics & Civics",
    "History & Archaeology", "Technology & Engineering",
    "Philosophy & Logic", "Arts & Architecture", "Health & Medicine",
    "Miscellaneous Global Facts",
}

VALID_VERIFICATION_TYPES = {
    "peer_reviewed", "government", "encyclopedia", "institution",
}

MAX_CONTENT_LEN = 280
COMPLEXITY_LABELS = {
    1: "pre_k / elementary",
    2: "middle",
    3: "high_school",
    4: "undergraduate",
    5: "graduate / postgraduate",
}

SCHEMA = """
CREATE TABLE IF NOT EXISTS facts (
    fact_id             TEXT PRIMARY KEY,
    category            TEXT NOT NULL,
    subcategory         TEXT,
    content             TEXT NOT NULL,
    extended_content    TEXT,
    verification_source TEXT NOT NULL,
    verification_type   TEXT NOT NULL,
    complexity_rating   INTEGER NOT NULL CHECK(complexity_rating BETWEEN 1 AND 5),
    language_neutral    INTEGER NOT NULL DEFAULT 1,
    tags                TEXT,
    math_domains        TEXT,
    language_concepts   TEXT,
    created_at          TEXT NOT NULL,
    last_verified       TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_facts_category   ON facts(category);
CREATE INDEX IF NOT EXISTS idx_facts_complexity ON facts(complexity_rating);
"""


def validate_fact(fact: Dict) -> List[str]:
    """Return a list of validation errors (empty list == valid)."""
    errors: List[str] = []

    for field in ("content", "category", "complexity_rating",
                  "verification_source", "verification_type"):
        if not fact.get(field):
            errors.append(f"missing required field: {field}")

    if errors:  # don't probe further if structurally broken
        return errors

    if fact["category"] not in REQUIRED_CATEGORIES:
        errors.append(f"category not in whitelist: {fact['category']!r}")

    if fact["verification_type"] not in VALID_VERIFICATION_TYPES:
        errors.append(f"bad verification_type: {fact['verification_type']!r}")

    cr = fact["complexity_rating"]
    if not isinstance(cr, int) or not (1 <= cr <= 5):
        errors.append(f"complexity_rating out of range: {cr!r}")

    if len(fact["content"]) > MAX_CONTENT_LEN:
        errors.append(f"content exceeds {MAX_CONTENT_LEN} chars "
                      f"({len(fact['content'])})")

    src = fact["verification_source"]
    if not (src.startswith("http") or src.startswith("ISBN")
            or src.startswith("DOI")):
        errors.append("verification_source must be a URL / ISBN / DOI")

    return errors


def insert_fact(conn: sqlite3.Connection, fact: Dict) -> str:
    fact_id = fact.get("fact_id") or str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()
    conn.execute(
        """
        INSERT OR REPLACE INTO facts (
            fact_id, category, subcategory, content, extended_content,
            verification_source, verification_type, complexity_rating,
            language_neutral, tags, math_domains, language_concepts,
            created_at, last_verified
        ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """,
        (
            fact_id,
            fact["category"],
            fact.get("subcategory", ""),
            fact["content"],
            fact.get("extended_content", ""),
            fact["verification_source"],
            fact["verification_type"],
            fact["complexity_rating"],
            1 if fact.get("language_neutral", True) else 0,
            json.dumps(fact.get("tags", [])),
            json.dumps(fact.get("math_domains", [])),
            json.dumps(fact.get("language_concepts", [])),
            now,
            fact.get("last_verified", now),
        ),
    )
    return fact_id


def seed(db_path: str, facts: List[Dict]) -> Dict:
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.executescript(SCHEMA)

    stats = {
        "attempted": len(facts),
        "inserted": 0,
        "rejected": 0,
        "by_category": {},
        "by_complexity": {k: 0 for k in COMPLEXITY_LABELS},
        "rejections": [],
    }

    with conn:
        for i, fact in enumerate(facts):
            errs = validate_fact(fact)
            if errs:
                stats["rejected"] += 1
                stats["rejections"].append((i, errs))
                continue
            insert_fact(conn, fact)
            stats["inserted"] += 1
            cat = fact["category"]
            stats["by_category"][cat] = stats["by_category"].get(cat, 0) + 1
            stats["by_complexity"][fact["complexity_rating"]] += 1

    with conn:
        conn.execute("ANALYZE facts")
    conn.execute("VACUUM")
    conn.close()
    return stats


def report(stats: Dict) -> None:
    line = "=" * 56
    print(f"\n{line}\nTAAEVON FACT SEEDING REPORT\n{line}")
    print(f"Attempted : {stats['attempted']:>6,}")
    print(f"Inserted  : {stats['inserted']:>6,}")
    print(f"Rejected  : {stats['rejected']:>6,}")

    print("\nBy category")
    for cat in sorted(stats["by_category"]):
        print(f"  {cat:<28} {stats['by_category'][cat]:>5}")

    print("\nBy complexity")
    for lvl, label in COMPLEXITY_LABELS.items():
        print(f"  L{lvl} {label:<24} {stats['by_complexity'][lvl]:>5}")

    if stats["rejections"]:
        print("\nRejections")
        for idx, errs in stats["rejections"]:
            print(f"  #{idx}: {'; '.join(errs)}")

    progress = stats["inserted"] / 10_000 * 100
    print(f"\nProgress toward 10,000 target: {progress:.2f}%")
    print(line)


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python tools/seed_facts.py <db_path> <facts_json_path>")
        return 1

    db_path, facts_path = sys.argv[1], sys.argv[2]
    with open(facts_path, "r", encoding="utf-8") as fh:
        facts = json.load(fh)

    stats = seed(db_path, facts)
    report(stats)
    return 0 if stats["rejected"] == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
