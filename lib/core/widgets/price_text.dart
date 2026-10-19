import 'package:flutter/material.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';

/// Final price in bold, original price struck through next to it.
class PriceText extends StatelessWidget {
  const PriceText({
    required this.price,
    required this.finalPrice,
    this.large = false,
    super.key,
  });

  final double price;
  final double finalPrice;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = finalPrice < price;
    final finalLabel = Formatters.price(finalPrice);
    final originalLabel = Formatters.price(price);
    return Semantics(
      label: hasDiscount
          ? context.l10n.priceLabel(finalLabel, originalLabel)
          : finalLabel,
      excludeSemantics: true,
      // One unit: if the line is too wide (large font, narrow card) it scales
      // down together instead of overflowing or cutting a digit off.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              finalLabel,
              maxLines: 1,
              style:
                  (large
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.titleMedium)
                      ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (hasDiscount) ...[
              Gaps.sm,
              Text(
                originalLabel,
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
