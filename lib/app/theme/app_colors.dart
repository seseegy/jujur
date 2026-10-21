import 'package:flutter/material.dart';

/// Color roles. Contrast of text roles against their background was checked
/// to be at least 4.5:1 (WCAG AA) in both themes.
abstract final class AppColors {
  // Light
  static const lightBackground = Color(0xFFF7F6F2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFEFEEE8);
  static const lightPrimary = Color(0xFF285747);
  static const lightPrimaryContainer = Color(0xFFDDE8E1);
  static const lightOnPrimaryContainer = Color(0xFF15372B);
  static const lightText = Color(0xFF252824);
  static const lightTextSecondary = Color(0xFF62665F);
  static const lightDivider = Color(0xFFE4E3DC);
  static const lightBorder = Color(0xFFCFCEC6);
  static const lightSuccess = Color(0xFF2F6B4A);
  static const lightWarning = Color(0xFF8A5A0B);
  static const lightError = Color(0xFFAE3B33);

  // Dark
  static const darkBackground = Color(0xFF151715);
  static const darkSurface = Color(0xFF1D201E);
  static const darkSurfaceMuted = Color(0xFF262A27);
  static const darkPrimary = Color(0xFF93C7AE);
  static const darkPrimaryContainer = Color(0xFF24443A);
  static const darkOnPrimaryContainer = Color(0xFFCFE6DA);
  static const darkText = Color(0xFFECEAE4);
  static const darkTextSecondary = Color(0xFFA9ADA6);
  static const darkDivider = Color(0xFF2E322F);
  static const darkBorder = Color(0xFF444944);
  static const darkSuccess = Color(0xFF8CC9A3);
  static const darkWarning = Color(0xFFDDB46A);
  static const darkError = Color(0xFFEC8F86);
}

/// Semantic colors that are not part of [ColorScheme].
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.muted,
    required this.divider,
  });

  final Color success;
  final Color warning;

  /// Neutral color for "not recorded" and "not applicable".
  final Color muted;
  final Color divider;

  static const light = StatusColors(
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    muted: AppColors.lightTextSecondary,
    divider: AppColors.lightDivider,
  );

  static const dark = StatusColors(
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    muted: AppColors.darkTextSecondary,
    divider: AppColors.darkDivider,
  );

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  @override
  StatusColors copyWith({Color? success, Color? warning, Color? muted, Color? divider}) => StatusColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    muted: muted ?? this.muted,
    divider: divider ?? this.divider,
  );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
