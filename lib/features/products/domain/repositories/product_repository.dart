import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

abstract interface class ProductRepository {
  /// One page of products matching [query], starting at [skip].
  Future<Result<ProductPage>> getProducts(
    ProductQuery query, {
    required int skip,
  });

  Future<Result<List<Category>>> getCategories();

  /// Fails with `NotFoundFailure` for unknown ids (e.g. 9999).
  Future<Result<ProductDetails>> getProduct(int id);
}
