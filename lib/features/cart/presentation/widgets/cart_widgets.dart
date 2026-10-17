import 'package:flutter/material.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_palette.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/app_network_image.dart';
import 'package:shopsphere/core/widgets/price_text.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

/// One cart line: picture, name, price, quantity and a remove button.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.onTap,
    super.key,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final product = item.product;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Insets.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.md),
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: SizedBox.square(
                    dimension: 84,
                    child: AppNetworkImage(url: product.thumbnail),
                  ),
                ),
              ),
              Gaps.md,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.removeItem,
                          visualDensity: VisualDensity.compact,
                          onPressed: onRemove,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                    PriceText(
                      price: product.price,
                      finalPrice: product.finalPrice,
                    ),
                    Gaps.sm,
                    Wrap(
                      spacing: Insets.md,
                      runSpacing: Insets.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        QuantityStepper(
                          dense: true,
                          value: item.quantity,
                          max: item.maxQuantity,
                          onChanged: onQuantityChanged,
                        ),
                        Text(
                          Formatters.price(item.total),
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtotal / discount / total rows.
class CartTotals extends StatelessWidget {
  const CartTotals({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    Widget row(String label, String value, {TextStyle? style, Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.xs),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(
              value,
              style: (style ?? const TextStyle()).copyWith(color: color),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        row(l10n.subtotal, Formatters.price(summary.subtotal)),
        if (summary.discount > 0)
          row(
            l10n.discount,
            '− ${Formatters.price(summary.discount)}',
            color: context.palette.success,
          ),
        const Divider(height: Insets.lg),
        row(
          l10n.total,
          Formatters.price(summary.total),
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
