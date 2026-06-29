"""Parser shape-contract check: every bundled JSON record must satisfy the
assumptions the Dart `fromJson` parsers make. A mismatch throws on a real device
but is invisible to `flutter analyze`, `flutter build`, and the unit tests (which
use in-memory stubs, not the real bundle). Run in CI so adding data can never
silently reintroduce a device parse crash.

Contracts (kept in sync with the Dart source):

  FactEntity.fromJson  (lib/features/fact_engine/domain/fact_entity.dart)
    required non-null String : category, content, verification_source
    required int (NOT float)  : complexity_rating   # `as int` throws on 3.0
    optional String?          : fact_id, subcategory

  LexiconEntry.fromJson  (lib/features/language/domain/lexicon_entry.dart)
    required non-null String : source_language, target_language, base_term,
                               translated_term, lexical_category
    optional num?            : syllable_count, math_extracted_value

  Container shapes:
    facts_seed.json   -> top-level JSON array of objects
    lexicon_seed.json -> top-level object with 'words' = array of objects

Usage: python tools/check_data_shape.py [PROJECT_ROOT]   (root defaults to ".")
Exits non-zero (and lists every offending record) on any mismatch.
"""
import json
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
FACTS = f"{ROOT}/assets/data/facts_seed.json"
LEX = f"{ROOT}/assets/data/lexicon_seed.json"

problems = []


def req_str(rec, key, where):
    v = rec.get(key, KeyError)
    if v is KeyError:
        problems.append(f"{where}: missing required string key '{key}'")
    elif not isinstance(v, str):
        problems.append(
            f"{where}: '{key}' is {type(v).__name__} ({v!r}); Dart expects non-null String")


def is_int_not_bool(v):
    return isinstance(v, int) and not isinstance(v, bool)


def check_facts():
    with open(FACTS, encoding="utf-8") as fh:
        data = json.load(fh)
    if not isinstance(data, list):
        problems.append(
            f"facts_seed.json: top-level is {type(data).__name__}; datasource casts `as List`")
        return 0
    for i, rec in enumerate(data):
        where = f"facts[{i}]"
        if not isinstance(rec, dict):
            problems.append(f"{where}: element is {type(rec).__name__}, expected object")
            continue
        for k in ("category", "content", "verification_source"):
            req_str(rec, k, where)
        cr = rec.get("complexity_rating", KeyError)
        if cr is KeyError:
            problems.append(f"{where}: missing required 'complexity_rating'")
        elif not is_int_not_bool(cr):
            problems.append(
                f"{where}: complexity_rating is {type(cr).__name__} ({cr!r}); "
                "Dart `as int` THROWS on a non-int")
    return len(data)


def check_lexicon():
    with open(LEX, encoding="utf-8") as fh:
        data = json.load(fh)
    if not isinstance(data, dict):
        problems.append(
            f"lexicon_seed.json: top-level is {type(data).__name__}; datasource casts `as Map`")
        return 0
    words = data.get("words", KeyError)
    if words is KeyError:
        problems.append("lexicon_seed.json: missing 'words' key")
        return 0
    if not isinstance(words, list):
        problems.append(
            f"lexicon_seed.json: 'words' is {type(words).__name__}; datasource casts `as List`")
        return 0
    for i, rec in enumerate(words):
        where = f"words[{i}]"
        if not isinstance(rec, dict):
            problems.append(f"{where}: element is {type(rec).__name__}, expected object")
            continue
        for k in ("source_language", "target_language", "base_term",
                  "translated_term", "lexical_category"):
            req_str(rec, k, where)
        for k in ("syllable_count", "math_extracted_value"):
            if k in rec and rec[k] is not None and not isinstance(rec[k], (int, float)):
                problems.append(
                    f"{where}: '{k}' is {type(rec[k]).__name__}; Dart expects num?")
    return len(words)


def main():
    nf = check_facts()
    nw = check_lexicon()
    print(f"Validated {nf} facts and {nw} lexicon words against Dart parser assumptions.")
    if not problems:
        print("OK — every record matches the fromJson type/required-key contract.")
        return
    print(f"\n{len(problems)} SHAPE MISMATCH(ES) — these would throw on device:")
    for p in problems[:200]:
        print(f"  - {p}")
    sys.exit(1)


if __name__ == "__main__":
    main()
