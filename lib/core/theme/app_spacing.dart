import 'package:flutter/widgets.dart';

/// The spacing scale. Only these values are used for padding and gaps, which
/// keeps every screen on the same 4-point rhythm.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal padding for page content.
  static const page = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Ready-made gaps so layouts read like `Gaps.md` instead of magic numbers.
abstract final class Gaps {
  static const xs = SizedBox(width: Insets.xs, height: Insets.xs);
  static const sm = SizedBox(width: Insets.sm, height: Insets.sm);
  static const md = SizedBox(width: Insets.md, height: Insets.md);
  static const lg = SizedBox(width: Insets.lg, height: Insets.lg);
  static const xl = SizedBox(width: Insets.xl, height: Insets.xl);
  static const xxl = SizedBox(width: Insets.xxl, height: Insets.xxl);
}
