import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightTextSecondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSurfaceMuted,
      onSecondaryContainer: AppColors.lightText,
      error: AppColors.lightError,
      onError: Colors.white,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerLowest: AppColors.lightSurface,
      surfaceContainerLow: AppColors.lightSurface,
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerHigh: AppColors.lightSurfaceMuted,
      surfaceContainerHighest: AppColors.lightSurfaceMuted,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      inverseSurface: AppColors.lightText,
      onInverseSurface: AppColors.lightBackground,
      inversePrimary: AppColors.darkPrimary,
    ),
    status: StatusColors.light,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: Color(0xFF0E2A1F),
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkTextSecondary,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.darkSurfaceMuted,
      onSecondaryContainer: AppColors.darkText,
      error: AppColors.darkError,
      onError: Color(0xFF3A0A06),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceMuted,
      surfaceContainerHighest: AppColors.darkSurfaceMuted,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      inverseSurface: AppColors.darkText,
      onInverseSurface: AppColors.darkBackground,
      inversePrimary: AppColors.lightPrimary,
    ),
    status: StatusColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required StatusColors status,
  }) {
    final text = AppTypography.textTheme(scheme.onSurface, scheme.onSurfaceVariant).apply(fontFamily: 'Roboto');
    final inputBorder = OutlineInputBorder(
      borderRadius: Radii.smallAll,
      borderSide: BorderSide(color: scheme.outline),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: [status],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall!.copyWith(
            color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        contentPadding: Space.pageInsets,
        minVerticalPadding: Space.sm,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: scheme.primary, width: 2)),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: scheme.error, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
        labelStyle: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: text.bodySmall,
        errorMaxLines: 3,
        helperMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: Radii.smallAll),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: Radii.smallAll),
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: Radii.smallAll),
          textStyle: text.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mediumAll),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: Radii.smallAll),
        side: BorderSide(color: scheme.outline),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.bodyMedium,
        showCheckmark: true,
        checkmarkColor: scheme.onPrimaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: Radii.smallAll),
          side: BorderSide(color: scheme.outline),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          minimumSize: const Size(48, minTouchTarget),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.medium)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mediumAll),
        titleTextStyle: text.titleMedium!.copyWith(fontSize: 18),
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: Radii.smallAll),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(color: scheme.onInverseSurface),
        actionTextColor: brightness == Brightness.light ? AppColors.darkPrimary : AppColors.lightPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Icon(Icons.check, size: 16) : null,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.mediumAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
      ),
    );
  }
}
