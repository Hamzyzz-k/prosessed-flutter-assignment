import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_palette.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/app_network_image.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/price_text.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';
import 'package:shopsphere/core/widgets/skeleton.dart';
import 'package:shopsphere/core/widgets/status_view.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';

/// Full-screen product details (phones and medium tablets).
class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ProductDetailsView(
        productId: productId,
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.shop),
      ),
    );
  }
}

/// The details content, used both as a page and as the tablet side pane.
class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({
    required this.productId,
    required this.onBack,
    this.embedded = false,
    super.key,
  });

  final int productId;
  final VoidCallback onBack;

  /// True inside the master–detail pane (no Hero, no app bar).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<ProductDetailsCubit>(param1: productId);
        unawaited(cubit.load());
        return cubit;
      },
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) => switch (state) {
          ProductDetailsLoading() => const _DetailsSkeleton(),
          ProductDetailsFailure(isNotFound: true) => EmptyView(
            icon: Icons.search_off_rounded,
            title: context.l10n.productNotFoundTitle,
            message: context.l10n.productNotFoundMessage,
            actionLabel: context.l10n.backToShop,
            actionIcon: Icons.arrow_back_rounded,
            onAction: onBack,
          ),
          ProductDetailsFailure(:final failure) => ErrorView(
            failure: failure,
            onRetry: () => context.read<ProductDetailsCubit>().load(),
          ),
          ProductDetailsLoaded(:final product, :final quantity) => _Details(
            product: product,
            quantity: quantity,
            useHero: !embedded,
          ),
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.product,
    required this.quantity,
    required this.useHero,
  });

  final ProductDetails product;
  final int quantity;
  final bool useHero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Gallery(product: product, useHero: useHero),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(Insets.lg),
                sliver: SliverList.list(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.brand != null)
                                Text(
                                  l10n.byBrand(product.brand!),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              Text(
                                product.title,
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        WishlistButton(product: product),
                      ],
                    ),
                    Gaps.sm,
                    Wrap(
                      spacing: Insets.md,
                      runSpacing: Insets.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RatingBadge(rating: product.rating),
                        Text(
                          l10n.reviewsTitle(product.reviews.length),
                          style: muted,
                        ),
                        _StockLabel(product: product),
                      ],
                    ),
                    Gaps.lg,
                    Wrap(
                      spacing: Insets.md,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PriceText(
                          price: product.price,
                          finalPrice: product.finalPrice,
                          large: true,
                        ),
                        if (product.hasDiscount)
                          DiscountBadge(percent: product.discountPercentage),
                      ],
                    ),
                    Gaps.xl,
                    Text(
                      l10n.descriptionTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    Gaps.sm,
                    Text(product.description, style: theme.textTheme.bodyLarge),
                    Gaps.lg,
                    for (final (icon, text) in [
                      (Icons.local_shipping_outlined, product.shipping),
                      (Icons.verified_outlined, product.warranty),
                      (Icons.assignment_return_outlined, product.returnPolicy),
                    ])
                      if (text != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(icon),
                          title: Text(text),
                        ),
                    Gaps.lg,
                    Text(
                      l10n.reviewsTitle(product.reviews.length),
                      style: theme.textTheme.titleMedium,
                    ),
                    Gaps.sm,
                    if (product.reviews.isEmpty)
                      Text(l10n.noReviews, style: muted)
                    else
                      for (final review in product.reviews)
                        _ReviewTile(review: review),
                  ],
                ),
              ),
            ],
          ),
        ),
        _AddToCartBar(product: product, quantity: quantity),
      ],
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.product, required this.useHero});

  final ProductDetails product;
  final bool useHero;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.gallery;
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final height = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      220.0,
      420.0,
    );

    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final image = Padding(
                  padding: const EdgeInsets.all(Insets.lg),
                  child: AppNetworkImage(
                    url: images[index],
                    semanticLabel:
                        '${widget.product.title}, '
                        '${l10n.imagePosition(index + 1, images.length)}',
                  ),
                );
                // Only the first image flies in from the grid thumbnail.
                return index == 0 && widget.useHero
                    ? Hero(tag: productHeroTag(widget.product.id), child: image)
                    : image;
              },
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.md),
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < images.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? scheme.primary
                              : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final (text, color, icon) = !product.inStock
        ? (l10n.outOfStock, scheme.error, Icons.block_rounded)
        : product.isLowStock
        ? (l10n.lowStock(product.stock), palette.rating, Icons.bolt_rounded)
        : (l10n.inStock, palette.success, Icons.check_circle_rounded);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        Gaps.xs,
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              review.reviewerName.isEmpty ? '?' : review.reviewerName[0],
            ),
          ),
          Gaps.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: Insets.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      review.reviewerName,
                      style: theme.textTheme.titleSmall,
                    ),
                    RatingBadge(rating: review.rating.toDouble()),
                    if (review.date != null)
                      Text(
                        Formatters.date(review.date!, locale),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                Gaps.xs,
                Text(review.comment, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.product, required this.quantity});

  final ProductDetails product;
  final int quantity;

  Future<void> _add(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    // Optional so the view also works outside the app router (tests).
    final router = GoRouter.maybeOf(context);
    unawaited(HapticFeedback.lightImpact());
    await context.read<CartCubit>().add(product, quantity: quantity);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.addedToCart),
          action: router == null
              ? null
              : SnackBarAction(
                  label: l10n.viewCart,
                  onPressed: () => router.go(Routes.cart),
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inStock = product.inStock;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Insets.md),
          child: Row(
            children: [
              QuantityStepper(
                value: inStock ? quantity : 0,
                max: inStock ? product.stock : 0,
                onChanged: inStock
                    ? context.read<ProductDetailsCubit>().setQuantity
                    : null,
              ),
              Gaps.md,
              Expanded(
                child: FilledButton.icon(
                  onPressed: inStock ? () => _add(context) : null,
                  icon: Icon(
                    inStock
                        ? Icons.add_shopping_cart_rounded
                        : Icons.remove_shopping_cart_outlined,
                  ),
                  label: Text(inStock ? l10n.addToCart : l10n.outOfStock),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1.2, child: SkeletonBox(radius: Radii.lg)),
            Gaps.xl,
            SkeletonBox(height: 14, width: 90),
            Gaps.sm,
            SkeletonBox(height: 26),
            Gaps.sm,
            SkeletonBox(height: 26, width: 200),
            Gaps.lg,
            SkeletonBox(height: 32, width: 140),
            Gaps.xl,
            SkeletonBox(height: 14),
            Gaps.sm,
            SkeletonBox(height: 14),
            Gaps.sm,
            SkeletonBox(height: 14, width: 220),
          ],
        ),
      ),
    );
  }
}
