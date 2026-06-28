import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/typography.dart';

/// Builds the global [ThemeData] from Taaevon design tokens.
abstract class TaaevonTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: TaaevonColors.backgroundBase,
      colorScheme: const ColorScheme.light(
        primary: TaaevonColors.primaryAction,
        secondary: TaaevonColors.secondaryAction,
        surface: TaaevonColors.backgroundAlt,
        error: TaaevonColors.error,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: TaaevonTypography.display,
        headlineSmall: TaaevonTypography.heading,
        bodyLarge: TaaevonTypography.body,
        labelMedium: TaaevonTypography.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TaaevonColors.primaryAction,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(TaaevonDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(TaaevonDimensions.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: TaaevonTypography.fontFamilyBody,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
