import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/widgets/app_network_image.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/price_text.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';

/// Hero tag shared by the grid thumbnail and the details image.
String productHeroTag(int id) => 'product-image-$id';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final ProductSummary product;
  final VoidCallback onTap;

  /// Highlighted in the tablet master–detail layout.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: selected
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: productHeroTag(product.id),
                    child: ColoredBox(
                      color: scheme.surfaceContainerLowest,
                      child: Padding(
                        padding: const EdgeInsets.all(Insets.sm),
                        child: AppNetworkImage(url: product.thumbnail),
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: Insets.sm,
                      left: Insets.sm,
                      child: DiscountBadge(percent: product.discountPercentage),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: WishlistButton(product: product),
                  ),
                  if (!product.inStock)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ColoredBox(
                        color: scheme.inverseSurface.withValues(alpha: 0.8),
                        child: Padding(
                          padding: const EdgeInsets.all(Insets.xs),
                          child: Text(
                            l10n.outOfStock,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onInverseSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.md,
                Insets.sm,
                Insets.md,
                Insets.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Gaps.xs,
                  RatingBadge(rating: product.rating),
                  Gaps.xs,
                  PriceText(
                    price: product.price,
                    finalPrice: product.finalPrice,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Heart toggle that reads and writes the wishlist.
class WishlistButton extends StatelessWidget {
  const WishlistButton({required this.product, super.key});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final liked = context.select<WishlistCubit, bool>(
      (c) => c.state.any((p) => p.id == product.id),
    );
    return IconButton(
      tooltip: liked ? l10n.removeFromWishlist : l10n.addToWishlist,
      isSelected: liked,
      onPressed: () => unawaited(context.read<WishlistCubit>().toggle(product)),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(liked),
          color: liked ? scheme.error : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
