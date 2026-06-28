#!/usr/bin/env python3
"""
Taaevon — deep dataset integrity checks.

Goes beyond the per-record validation in the seeders: detects duplicates,
numeral value mismatches, and coverage gaps that a row-by-row check misses.
Exit code is non-zero if any issue is found (so CI can gate on it).

Usage:
    python tools/validate_data.py assets/data/facts_seed.json assets/data/lexicon_seed.json
"""

import json
import sys
from collections import Counter

FACT_CATEGORIES = {
    "Mathematics & Logic", "Linguistics & Language", "Physical Sciences",
    "Life Sciences", "Earth & Geosciences", "Geopolitics & Civics",
    "History & Archaeology", "Technology & Engineering",
    "Philosophy & Logic", "Arts & Architecture", "Health & Medicine",
    "Miscellaneous Global Facts",
}
FACT_TYPES = {"peer_reviewed", "government", "encyclopedia", "institution"}
LEXICAL = {"academic", "everyday", "slang", "technical", "formal"}
CEFR = {"A1", "A2", "B1", "B2", "C1", "C2"}
NUMBER_WORDS = {
    "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
}


def check_facts(path):
    facts = json.load(open(path, encoding="utf-8"))
    issues = []

    seen = {}
    for i, f in enumerate(facts):
        key = f["content"].strip().lower()
        if key in seen:
            issues.append(f"fact #{i}: duplicate content of #{seen[key]}")
        seen[key] = i
        if f["category"] not in FACT_CATEGORIES:
            issues.append(f"fact #{i}: bad category {f['category']!r}")
        if f["verification_type"] not in FACT_TYPES:
            issues.append(f"fact #{i}: bad verification_type")
        if not (1 <= f["complexity_rating"] <= 5):
            issues.append(f"fact #{i}: complexity out of range")
        if len(f["content"]) > 280:
            issues.append(f"fact #{i}: content too long")
        src = f["verification_source"]
        if not (src.startswith("http") or src.startswith("ISBN")
                or src.startswith("DOI")):
            issues.append(f"fact #{i}: bad source")

    cats = Counter(f["category"] for f in facts)
    missing = FACT_CATEGORIES - set(cats)
    if missing:
        issues.append(f"categories with no facts: {sorted(missing)}")

    print(f"FACTS: {len(facts)} records, {len(cats)}/12 categories covered")
    return issues


def check_lexicon(path):
    payload = json.load(open(path, encoding="utf-8"))
    words = payload["words"]
    issues = []

    seen = {}
    numerals_by_lang = {}
    for i, w in enumerate(words):
        triple = (w["source_language"], w["target_language"], w["base_term"])
        if triple in seen:
            issues.append(f"word #{i}: duplicate {triple} of #{seen[triple]}")
        seen[triple] = i

        if w["lexical_category"] not in LEXICAL:
            issues.append(f"word #{i}: bad lexical_category")
        if w.get("cefr_level") and w["cefr_level"] not in CEFR:
            issues.append(f"word #{i}: bad cefr_level")
        if int(w.get("syllable_count", 0)) < 1:
            issues.append(f"word #{i}: syllable_count < 1")

        if w.get("part_of_speech") == "numeral":
            expected = NUMBER_WORDS.get(w["base_term"].lower())
            if expected is not None and w.get("math_extracted_value") != expected:
                issues.append(
                    f"word #{i} ({w['target_language']} {w['base_term']}): "
                    f"math_extracted_value {w.get('math_extracted_value')} "
                    f"!= {expected}")
            numerals_by_lang.setdefault(w["target_language"], set()).add(
                w.get("math_extracted_value"))

    # Each target language should cover numbers 1..3 (used by the activities).
    for lang, values in numerals_by_lang.items():
        for n in (1, 2, 3):
            if n not in values:
                issues.append(f"language {lang}: missing numeral {n}")

    langs = Counter(w["target_language"] for w in words)
    print(f"LEXICON: {len(words)} words across targets {dict(langs)}; "
          f"numerals per lang: "
          f"{ {k: len(v) for k, v in numerals_by_lang.items()} }")
    return issues


def main():
    if len(sys.argv) < 3:
        print("Usage: python tools/validate_data.py <facts.json> <lexicon.json>")
        return 1
    issues = check_facts(sys.argv[1]) + check_lexicon(sys.argv[2])
    if issues:
        print(f"\n{len(issues)} integrity issue(s):")
        for x in issues:
            print("  " + x)
        return 1
    print("\nAll integrity checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
