"""WCAG 2.1 contrast contract for the Taaevon color system.

The PRD mandates "high-contrast, ADA-compliant interactive colors". This computes
the actual contrast ratio for each meaningful foreground/background pair the app
uses (compositing the ~72% white card surface over the ice-blue base) and asserts
it meets WCAG AA: 4.5:1 for normal text, 3:1 for large text and UI components.

Mirrors lib/core/constants/colors.dart — keep the COLORS map in sync if tokens
change. Run in CI so a future palette tweak can't silently fail ADA contrast.

Usage: python tools/check_contrast.py   (no args; colors are inlined)
"""
import sys

# Mirror of lib/core/constants/colors.dart (ARGB hex; 6-digit = opaque).
COLORS = {
    "backgroundBase": "FFE6F0FA",
    "backgroundAlt": "FFEDF4FB",
    "backgroundDeep": "FFD4E6F5",
    "primaryAction": "FF1A3C5E",
    "secondaryAction": "FF0D6EFD",
    "success": "FF0B6E4F",
    "warning": "FF8B4000",
    "error": "FF7B1010",
    "neutralText": "FF1C2B3A",
    "secondaryText": "FF3D5A6E",
    "disabled": "FF8FA6B5",
    "accentB": "FF1B5299",
    "mathAccent": "FF1A3C5E",
    "languageAccent": "FF0D6EFD",
    "cardBackground": "B8FFFFFF",  # ~72% white over whatever is behind it
    "factBackground": "FF1A3C5E",
    "factText": "FFFFFFFF",
}


def argb(hexstr):
    h = hexstr.lstrip("#")
    if len(h) == 6:
        h = "FF" + h
    a = int(h[0:2], 16) / 255.0
    r = int(h[2:4], 16)
    g = int(h[4:6], 16)
    b = int(h[6:8], 16)
    return a, (r, g, b)


def over(fg_name, base_name):
    """Composite a (possibly translucent) color over an opaque base -> opaque rgb."""
    a, (r, g, b) = argb(COLORS[fg_name])
    _, (br, bg, bb) = argb(COLORS[base_name])
    return (
        round(a * r + (1 - a) * br),
        round(a * g + (1 - a) * bg),
        round(a * b + (1 - a) * bb),
    )


def lum(rgb):
    def chan(c):
        cs = c / 255.0
        return cs / 12.92 if cs <= 0.03928 else ((cs + 0.055) / 1.055) ** 2.4
    r, g, b = rgb
    return 0.2126 * chan(r) + 0.7152 * chan(g) + 0.0722 * chan(b)


def ratio(fg, bg):
    l1, l2 = lum(fg), lum(bg)
    hi, lo = max(l1, l2), min(l1, l2)
    return (hi + 0.05) / (lo + 0.05)


def rgb_of(name):
    return argb(COLORS[name])[1]


# Effective opaque surfaces.
CARD = over("cardBackground", "backgroundBase")  # card over the ice-blue base

# (label, foreground rgb, background rgb, min ratio)
CHECKS = [
    ("neutralText / backgroundBase (body)", rgb_of("neutralText"), rgb_of("backgroundBase"), 4.5),
    ("neutralText / card", rgb_of("neutralText"), CARD, 4.5),
    ("secondaryText / backgroundBase (label)", rgb_of("secondaryText"), rgb_of("backgroundBase"), 4.5),
    ("secondaryText / card", rgb_of("secondaryText"), CARD, 4.5),
    ("secondaryText / backgroundDeep (locked badge stroke, UI)", rgb_of("secondaryText"), rgb_of("backgroundDeep"), 3.0),
    ("primaryAction / backgroundBase", rgb_of("primaryAction"), rgb_of("backgroundBase"), 4.5),
    ("mathAccent / card (MATH title 16px)", rgb_of("mathAccent"), CARD, 4.5),
    ("accentB / card (LANGUAGE title 16px)", rgb_of("accentB"), CARD, 4.5),
    ("success / card (correct / streak)", rgb_of("success"), CARD, 4.5),
    ("warning / card", rgb_of("warning"), CARD, 4.5),
    ("error / card", rgb_of("error"), CARD, 4.5),
    ("factText / factBackground (interstitial)", rgb_of("factText"), rgb_of("factBackground"), 4.5),
]

fails = []
print("WCAG AA contrast contract (4.5:1 text / 3:1 large+UI):")
for label, fg, bg, minr in CHECKS:
    r = ratio(fg, bg)
    ok = r >= minr
    print(f"  [{'OK ' if ok else 'FAIL'}] {r:5.2f}:1  (>= {minr})  {label}")
    if not ok:
        fails.append((label, r, minr))

if fails:
    print(f"\n{len(fails)} pair(s) below threshold:")
    for label, r, minr in fails:
        print(f"  - {label}: {r:.2f}:1 < {minr}:1")
    sys.exit(1)
print("\nOK — all audited foreground/background pairs meet WCAG AA.")
