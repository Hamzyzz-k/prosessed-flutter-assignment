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
      child: Wrap(
        spacing: Insets.sm,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            finalLabel,
            style:
                (large
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.titleMedium)
                    ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (hasDiscount)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                originalLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
