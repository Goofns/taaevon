#!/usr/bin/env python3
"""
Structural audit for the Dart sources — a lightweight pre-compile check for
environments without the Flutter SDK.

Checks, per file:
  1. Delimiter balance for () [] {} — a tokenizer that ignores comments, and
     single/double/triple/raw string literals (so interpolation braces and
     bracket characters inside strings don't skew the count).
  2. Import resolution — every `package:taaevon/...` and relative import points
     at a file that exists. External packages (dart:, package:flutter, etc.)
     are assumed present.
  3. part / part-of consistency — each `part 'x.dart'` exists, and each part
     file declares `part of`.

This does NOT type-check. It catches the structural errors that otherwise only
surface at `flutter analyze` time.

Usage:  python tools/audit_dart.py [root]
"""

import os
import re
import sys

OPENS = set("([{")
CLOSE_TO_OPEN = {")": "(", "]": "[", "}": "{"}


def scan_delimiters(src: str):
    errors = []
    stack = []
    i, n, line = 0, len(src), 1

    while i < n:
        c = src[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        # line comment
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        # block comment
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                if src[i] == "\n":
                    line += 1
                i += 1
            i += 2
            continue
        # raw string
        if c == "r" and i + 1 < n and src[i + 1] in "'\"":
            q = src[i + 1]
            if src[i + 1 : i + 4] == q * 3:
                i += 4
                while i < n and src[i : i + 3] != q * 3:
                    if src[i] == "\n":
                        line += 1
                    i += 1
                i += 3
            else:
                i += 2
                while i < n and src[i] != q and src[i] != "\n":
                    i += 1
                i += 1
            continue
        # normal string
        if c in "'\"":
            q = c
            if src[i : i + 3] == q * 3:
                i += 3
                while i < n and src[i : i + 3] != q * 3:
                    if src[i] == "\\":
                        i += 2
                        continue
                    if src[i] == "\n":
                        line += 1
                    i += 1
                i += 3
            else:
                i += 1
                while i < n and src[i] != q:
                    if src[i] == "\\":
                        i += 2
                        continue
                    if src[i] == "\n":
                        break
                    i += 1
                i += 1
            continue
        if c in OPENS:
            stack.append((c, line))
            i += 1
            continue
        if c in CLOSE_TO_OPEN:
            if not stack or stack[-1][0] != CLOSE_TO_OPEN[c]:
                errors.append(f"unmatched {c!r} at line {line}")
            else:
                stack.pop()
            i += 1
            continue
        i += 1

    for oc, ol in stack:
        errors.append(f"unclosed {oc!r} opened at line {ol}")
    return errors


IMPORT_RE = re.compile(r"""^\s*import\s+['"]([^'"]+)['"]""")
PART_RE = re.compile(r"""^\s*part\s+(?!of\b)['"]([^'"]+)['"]""")
PARTOF_RE = re.compile(r"""^\s*part\s+of\s+['"]([^'"]+)['"]""")
PKG_PREFIX = "package:taaevon/"


def resolve(uri: str, file_path: str, lib_root: str):
    if uri.startswith("dart:") or (
        uri.startswith("package:") and not uri.startswith(PKG_PREFIX)
    ):
        return None  # external, assumed present
    if uri.startswith(PKG_PREFIX):
        return os.path.join(lib_root, uri[len(PKG_PREFIX):])
    return os.path.normpath(os.path.join(os.path.dirname(file_path), uri))


def audit(root: str):
    lib_root = os.path.join(root, "lib")
    targets = []
    for base in ("lib", "test"):
        for dirpath, _, names in os.walk(os.path.join(root, base)):
            for name in names:
                if name.endswith(".dart"):
                    targets.append(os.path.join(dirpath, name))

    total_errors = 0
    files_with_errors = 0
    for path in sorted(targets):
        with open(path, "r", encoding="utf-8") as fh:
            src = fh.read()
        errors = scan_delimiters(src)

        for line in src.splitlines():
            for rx, kind in ((IMPORT_RE, "import"), (PART_RE, "part")):
                m = rx.match(line)
                if not m:
                    continue
                resolved = resolve(m.group(1), path, lib_root)
                if resolved is None:
                    continue
                if not os.path.isfile(resolved):
                    errors.append(f"{kind} target missing: {m.group(1)}")
                elif kind == "part":
                    with open(resolved, encoding="utf-8") as pf:
                        if "part of" not in pf.read():
                            errors.append(
                                f"part target lacks 'part of': {m.group(1)}")

        rel = os.path.relpath(path, root)
        if errors:
            files_with_errors += 1
            total_errors += len(errors)
            print(f"FAIL  {rel}")
            for e in errors:
                print(f"        - {e}")
        else:
            print(f"ok    {rel}")

    print("\n" + "=" * 60)
    print(f"Scanned {len(targets)} Dart files")
    print(f"Files with issues: {files_with_errors}")
    print(f"Total issues:      {total_errors}")
    print("=" * 60)
    return 0 if total_errors == 0 else 1


if __name__ == "__main__":
    raise SystemExit(audit(sys.argv[1] if len(sys.argv) > 1 else "."))
