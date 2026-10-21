import 'package:flutter/widgets.dart';

/// Spacing scale (dp). Use these instead of ad-hoc values.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page padding.
  static const double page = 20;
  static const pageInsets = EdgeInsets.symmetric(horizontal: page);
}

/// The only corner radii used in the app.
abstract final class Radii {
  static const double small = 8;
  static const double medium = 12;
  static const smallAll = BorderRadius.all(Radius.circular(small));
  static const mediumAll = BorderRadius.all(Radius.circular(medium));
}

/// Minimum interactive size (Material guidance).
const double minTouchTarget = 48;
