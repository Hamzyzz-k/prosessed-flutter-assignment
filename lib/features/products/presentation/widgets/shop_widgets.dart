import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/widgets/skeleton.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

/// Grid layout shared by real cards and skeletons.
///
/// Each card is a square image plus a text block. The text block grows with
/// the system font size, so the height is computed instead of using a fixed
/// aspect ratio: no overflow even at 1.3× (or larger) text.
SliverGridDelegate productGridDelegate(BuildContext context, int columns) {
  final width = MediaQuery.sizeOf(context).width;
  return _ProductGridDelegate(
    columns: columns,
    textScale: MediaQuery.textScalerOf(context).scale(1),
    fallbackWidth: width,
  );
}

class _ProductGridDelegate extends SliverGridDelegate {
  const _ProductGridDelegate({
    required this.columns,
    required this.textScale,
    required this.fallbackWidth,
  });

  final int columns;
  final double textScale;
  final double fallbackWidth;

  static const double _spacing = Insets.md;

  /// Title (2 lines) + rating + price at 1× text, plus fixed padding.
  static const _textBlock = 112.0;
  static const _padding = 20.0;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final width = constraints.crossAxisExtent.isFinite
        ? constraints.crossAxisExtent
        : fallbackWidth;
    final tileWidth = (width - _spacing * (columns - 1)) / columns;
    final tileHeight = tileWidth + _padding + _textBlock * textScale;
    return SliverGridRegularTileLayout(
      crossAxisCount: columns,
      mainAxisStride: tileHeight + _spacing,
      crossAxisStride: tileWidth + _spacing,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(_ProductGridDelegate old) =>
      old.columns != columns || old.textScale != textScale;
}

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({required this.columns, super.key});

  final int columns;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: productGridDelegate(context, columns),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const Skeleton(child: _SkeletonCard()),
        childCount: columns * 3,
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(aspectRatio: 1, child: SkeletonBox(radius: Radii.lg)),
        Gaps.md,
        SkeletonBox(height: 14),
        Gaps.sm,
        SkeletonBox(height: 14, width: 80),
        Gaps.sm,
        SkeletonBox(height: 18, width: 60),
      ],
    );
  }
}

/// Search field with a clear button.
class ShopSearchField extends StatelessWidget {
  const ShopSearchField({
    required this.controller,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.clearSearch,
                  onPressed: onCleared,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

/// "All · Beauty · Fragrances …" horizontal chips.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Category> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(String?, String)>[
      (null, l10n.categoryAll),
      for (final c in categories) (c.slug, c.name),
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Insets.page,
        itemCount: items.length,
        separatorBuilder: (_, _) => Gaps.sm,
        itemBuilder: (context, index) {
          final (slug, name) = items[index];
          return ChoiceChip(
            label: Text(name),
            selected: slug == selected,
            onSelected: (_) => onSelected(slug),
          );
        },
      ),
    );
  }
}

/// Bottom sheet listing the sort options; returns the chosen one.
Future<ProductSort?> showSortSheet(BuildContext context, ProductSort current) {
  final l10n = context.l10n;
  final labels = {
    ProductSort.relevance: l10n.sortRelevance,
    ProductSort.priceLowHigh: l10n.sortPriceLowHigh,
    ProductSort.priceHighLow: l10n.sortPriceHighLow,
    ProductSort.rating: l10n.sortRating,
    ProductSort.titleAz: l10n.sortTitleAz,
  };
  return showModalBottomSheet<ProductSort>(
    context: context,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                0,
                Insets.xl,
                Insets.sm,
              ),
              child: Text(
                l10n.sortTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final entry in labels.entries)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Insets.xl,
                ),
                title: Text(entry.value),
                selected: entry.key == current,
                trailing: entry.key == current
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
            Gaps.sm,
          ],
        ),
      ),
    ),
  );
}

/// A thin banner shown at the top of the shop while offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.showingCache, super.key});

  final bool showingCache;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: scheme.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: scheme.onInverseSurface,
              ),
              Gaps.sm,
              Expanded(
                child: Text(
                  showingCache ? l10n.offlineCachedBanner : l10n.offlineBanner,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: scheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
