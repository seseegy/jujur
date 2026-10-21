import 'package:flutter/material.dart';

/// Type scale built on the platform font (Roboto on Android), which keeps
/// the APK small and supports dynamic text scaling.
abstract final class AppTypography {
  static const tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(Color text, Color secondary) => TextTheme(
    // Date heading on Today.
    headlineSmall: TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w500, color: text, letterSpacing: -0.2),
    // App bar titles.
    titleLarge: TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w500, color: text),
    // Row titles and dialog titles.
    titleMedium: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w500, color: text),
    titleSmall: TextStyle(fontSize: 14, height: 1.35, fontWeight: FontWeight.w500, color: text),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: text),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: text),
    bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: secondary),
    // Section labels.
    labelLarge: TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w500, color: text),
    labelMedium: TextStyle(fontSize: 12.5, height: 1.3, fontWeight: FontWeight.w600, color: secondary, letterSpacing: 0.6),
    labelSmall: TextStyle(fontSize: 11.5, height: 1.3, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.2),
  );
}

extension TextStyleX on TextStyle {
  TextStyle get tabular => copyWith(fontFeatures: AppTypography.tabular);
}
