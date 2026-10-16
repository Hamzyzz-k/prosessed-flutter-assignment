import 'package:flutter/material.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_palette.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';

/// ★ 4.6
class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.rating, super.key});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final value = Formatters.rating(rating);
    return Semantics(
      label: context.l10n.ratingLabel(value),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 18, color: context.palette.rating),
          const SizedBox(width: 2),
          Text(value, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Red "-12%" pill shown on discounted products.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({required this.percent, super.key});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.discount,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          context.l10n.discountBadge(Formatters.percent(percent)),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: palette.onDiscount,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
