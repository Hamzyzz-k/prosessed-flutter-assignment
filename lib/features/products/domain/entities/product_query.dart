import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

enum ProductSort { relevance, priceLowHigh, priceHighLow, rating, titleAz }

/// What the shopper is currently looking at: search text, category and sort.
class ProductQuery extends Equatable {
  const ProductQuery({
    this.search = '',
    this.category,
    this.sort = ProductSort.relevance,
  });

  static const pageSize = 20;

  final String search;

  /// Category slug, `null` for "All".
  final String? category;
  final ProductSort sort;

  bool get isSearching => search.trim().isNotEmpty;

  /// The plain "All, recommended" list. Only this one is cached offline.
  bool get isDefault =>
      !isSearching && category == null && sort == ProductSort.relevance;

  @override
  List<Object?> get props => [search, category, sort];
}

/// One page of results.
class ProductPage extends Equatable {
  const ProductPage({
    required this.items,
    required this.total,
    required this.skip,
    this.isFromCache = false,
  });

  final List<ProductSummary> items;
  final int total;
  final int skip;

  /// True when the network failed and these are saved results.
  final bool isFromCache;

  bool get hasMore => !isFromCache && skip + items.length < total;

  @override
  List<Object?> get props => [items, total, skip, isFromCache];
}

class Category extends Equatable {
  const Category({required this.slug, required this.name});

  final String slug;
  final String name;

  @override
  List<Object?> get props => [slug, name];
}
