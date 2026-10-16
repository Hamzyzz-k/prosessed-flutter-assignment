import 'package:flutter/material.dart';

/// Brand colours that Material's [ColorScheme] has no slot for.
///
/// Read them with `context.palette.rating` etc.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.rating,
    required this.discount,
    required this.onDiscount,
  });

  static const light = AppPalette(
    success: Color(0xFF1B7F3B),
    rating: Color(0xFFB7791F),
    discount: Color(0xFFD93A3F),
    onDiscount: Colors.white,
  );

  static const dark = AppPalette(
    success: Color(0xFF6DD58C),
    rating: Color(0xFFF6C35B),
    discount: Color(0xFFFF8A8C),
    onDiscount: Color(0xFF3B0A0C),
  );

  /// "In stock", order placed.
  final Color success;

  /// Star ratings.
  final Color rating;

  /// Discount badges.
  final Color discount;
  final Color onDiscount;

  @override
  AppPalette copyWith({
    Color? success,
    Color? rating,
    Color? discount,
    Color? onDiscount,
  }) {
    return AppPalette(
      success: success ?? this.success,
      rating: rating ?? this.rating,
      discount: discount ?? this.discount,
      onDiscount: onDiscount ?? this.onDiscount,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      success: Color.lerp(success, other.success, t)!,
      rating: Color.lerp(rating, other.rating, t)!,
      discount: Color.lerp(discount, other.discount, t)!,
      onDiscount: Color.lerp(onDiscount, other.onDiscount, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
