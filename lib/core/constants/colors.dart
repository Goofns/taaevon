import 'package:flutter/material.dart';

/// Taaevon colour system — Abstract Geometric Minimalism.
///
/// Background is a faint ice-blue; the geometric watermark layer sits at very
/// low opacity; foreground interactive colours are high-contrast and WCAG 2.1
/// AA compliant against the [backgroundBase].
abstract class TaaevonColors {
  // Background palette
  static const Color backgroundBase = Color(0xFFE6F0FA);
  static const Color backgroundAlt = Color(0xFFEDF4FB);
  static const Color backgroundDeep = Color(0xFFD4E6F5);

  // Geometric watermark layer (background shapes)
  static const Color polygonFill = Color(0xFFB8D4EC);
  static const Color gridLine = Color(0xFFC5DCF0);

  // Foreground interactive
  static const Color primaryAction = Color(0xFF1A3C5E);
  static const Color primaryActionPressed =
      Color(0xFF0D3050); // pressed (PRD §3.5)
  static const Color secondaryAction = Color(0xFF0D6EFD);
  static const Color success = Color(0xFF0B6E4F);
  static const Color warning = Color(0xFF8B4000);
  static const Color error = Color(0xFF7B1010);
  static const Color neutralText = Color(0xFF1C2B3A);
  static const Color secondaryText = Color(0xFF3D5A6E);
  static const Color disabled = Color(0xFF8FA6B5);

  // Accent geometry (interactive elements only)
  static const Color accentA = Color(0xFF2D6A9F);
  static const Color accentB = Color(0xFF1B5299);
  static const Color accentC = Color(0xFF0E4D78);
  static const Color accentD = Color(0xFF3B82C4);

  // Track accents
  static const Color mathAccent = Color(0xFF1A3C5E);
  static const Color languageAccent = Color(0xFF0D6EFD);

  // Fact interstitial (inverted for maximum contrast on transitions)
  static const Color factBackground = Color(0xFF1A3C5E);
  static const Color factText = Color(0xFFFFFFFF);
  static const Color factBadge = Color(0xFF0D6EFD);

  // Surfaces
  static const Color cardBackground = Color(0xB8FFFFFF); // ~72% white
  static const Color cardBorder = Color(0xFFC5DCF0);
  static const Color inputBackground = Color(0xE6FFFFFF); // ~90% white
  static const Color inputBorder = Color(0xFFB8D4EC);
  static const Color inputBorderActive = Color(0xFF0D6EFD);
}
