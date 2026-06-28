/// Spacing, radius, and sizing tokens used across the geometric UI.
abstract class TaaevonDimensions {
  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Radii
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusPill = 100;

  // Component sizing
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double progressHeight = 6;

  /// Minimum touch target (Apple HIG + Material): 44x44dp.
  static const double minTouchTarget = 44;

  /// Isometric background grid spacing.
  static const double gridSpacing = 48;
}
