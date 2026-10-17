import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Favourites, stored only on this device.
abstract interface class WishlistRepository {
  Future<Result<List<ProductSummary>>> load();
  Future<Result<void>> save(List<ProductSummary> items);
}

/// Adds the product if missing, removes it if present. Newest first.
List<ProductSummary> toggleWishlist(
  List<ProductSummary> items,
  ProductSummary product,
) {
  final exists = items.any((p) => p.id == product.id);
  return exists
      ? items.where((p) => p.id != product.id).toList()
      : [product, ...items];
}
