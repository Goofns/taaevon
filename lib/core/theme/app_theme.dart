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
        // Per-state background (PRD §3.5): pressed darkens, disabled greys out.
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TaaevonColors.disabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return TaaevonColors.primaryActionPressed;
            }
            return TaaevonColors.primaryAction;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(TaaevonDimensions.buttonHeight),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: TaaevonTypography.fontFamilyBody,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
