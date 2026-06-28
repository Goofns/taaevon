import 'package:flutter/material.dart';

import 'colors.dart';

/// Typography tokens. Font families are named here but are not bundled in the
/// scaffold — they fall back to the platform default until the .ttf assets are
/// added (see pubspec.yaml). Minimum body size is never below 16sp.
abstract class TaaevonTypography {
  static const String fontFamilyDisplay = 'Inter';
  static const String fontFamilyBody = 'Inter';
  static const String fontFamilyMono = 'JetBrainsMono';
  static const String fontFamilyUniversal = 'NotoSans';

  static const double minBodySize = 16;
  static const double minMathSize = 18;

  static const TextStyle display = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: TaaevonColors.neutralText,
    letterSpacing: 4, // wide tracking for the geometric wordmark
  );

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: TaaevonColors.neutralText,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: minBodySize,
    fontWeight: FontWeight.w400,
    color: TaaevonColors.neutralText,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: TaaevonColors.secondaryText,
    letterSpacing: 0.2,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: TaaevonColors.neutralText,
  );

  static const TextStyle factCard = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: TaaevonColors.factText,
    height: 1.6,
  );
}
