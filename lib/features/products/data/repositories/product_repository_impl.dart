import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote, this._local);

  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  @override
  Future<Result<ProductPage>> getProducts(
    ProductQuery query, {
    required int skip,
  }) {
    final cacheable = query.isDefault && skip == 0;
    return guard(() async {
      try {
        final page = await _remote.fetchProducts(query, skip: skip);
        if (cacheable) await _local.cacheFirstPage(page);
        return page.toEntity();
      } on NetworkException {
        final cached = cacheable ? _local.readFirstPage() : null;
        if (cached == null) rethrow;
        return cached.toEntity(isFromCache: true);
      }
    });
  }

  @override
  Future<Result<List<Category>>> getCategories() {
    return guard(() async {
      final categories = await _remote.fetchCategories();
      return categories.map((c) => c.toEntity()).toList();
    });
  }

  @override
  Future<Result<ProductDetails>> getProduct(int id) {
    return guard(() async => (await _remote.fetchProduct(id)).toEntity());
  }
}
