"""Asset declaration contract: every asset path the Dart code loads at runtime
(via rootBundle / AssetImage / any 'assets/...' literal) MUST be declared under
`flutter: assets:` in pubspec.yaml, or it throws "Unable to load asset" on device.

This is the deterministic guard for the class of bug where lexicon_seed.json was
loaded but never declared (so it shipped missing from the APK). A widget test
can't reliably cover this — `rootBundle` asset access is unreliable in the test
binding — but a static pubspec-vs-references check is exact and fast.

Usage: python tools/check_assets_declared.py [PROJECT_ROOT]   (root defaults ".")
Exits non-zero listing any referenced asset that isn't declared.
"""
import os
import re
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."


def declared_assets(pubspec_path):
    """Parse the `flutter: assets:` block (manual, to avoid a PyYAML dep)."""
    entries = []
    with open(pubspec_path, encoding="utf-8") as fh:
        lines = fh.readlines()
    in_assets = False
    for line in lines:
        stripped = line.strip()
        # entering the assets block: a key `assets:` indented under `flutter:`
        if re.match(r"^\s{2,}assets:\s*$", line):
            in_assets = True
            continue
        if not in_assets:
            continue
        if not stripped or stripped.startswith("#"):
            continue
        m = re.match(r"^\s+-\s*(\S+)", line)
        if m:
            entries.append(m.group(1))
            continue
        # a non-list, non-comment line ends the block (e.g. `fonts:` / dedent)
        if re.match(r"^\s{0,2}\S", line):
            break
    return entries


def is_declared(path, declared):
    for d in declared:
        if d.endswith("/"):
            # a directory entry covers files directly inside it
            if path.startswith(d) and "/" not in path[len(d):]:
                return True
        elif path == d:
            return True
    return False


def referenced_assets(root):
    refs = {}  # path -> first "file:line"
    pat = re.compile(r"""['"](assets/[^'"]+)['"]""")
    for dp, _, files in os.walk(os.path.join(root, "lib")):
        for f in files:
            if not f.endswith(".dart"):
                continue
            fp = os.path.join(dp, f)
            with open(fp, encoding="utf-8") as fh:
                for i, line in enumerate(fh, 1):
                    for m in pat.finditer(line):
                        a = m.group(1)
                        refs.setdefault(a, f"{os.path.relpath(fp, root)}:{i}")
    return refs


def main():
    pubspec = os.path.join(ROOT, "pubspec.yaml")
    declared = declared_assets(pubspec)
    refs = referenced_assets(ROOT)
    missing = [(a, where) for a, where in sorted(refs.items())
               if not is_declared(a, declared)]
    print(f"Declared asset entries: {declared}")
    print(f"Referenced asset paths: {len(refs)}")
    if not missing:
        print("OK — every referenced asset is declared in pubspec (will bundle).")
        return
    print(f"\n{len(missing)} UNDECLARED asset(s) — these throw 'Unable to load asset' on device:")
    for a, where in missing:
        print(f"  - {a}   (referenced at {where})")
    sys.exit(1)


if __name__ == "__main__":
    main()
