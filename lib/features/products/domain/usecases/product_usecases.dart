import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<Result<ProductPage>> call(ProductQuery query, {int skip = 0}) {
    // DummyJSON's search endpoint cannot also filter by category, so a
    // search always looks across every category.
    final effective = query.isSearching
        ? ProductQuery(search: query.search.trim(), sort: query.sort)
        : query;
    return _repository.getProducts(effective, skip: skip);
  }
}

class GetCategories {
  const GetCategories(this._repository);

  final ProductRepository _repository;

  Future<Result<List<Category>>> call() => _repository.getCategories();
}

class GetProductDetails {
  const GetProductDetails(this._repository);

  final ProductRepository _repository;

  Future<Result<ProductDetails>> call(int id) => _repository.getProduct(id);
}
