import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

abstract interface class ProductRemoteDataSource {
  Future<ProductPageModel> fetchProducts(
    ProductQuery query, {
    required int skip,
  });
  Future<List<CategoryModel>> fetchCategories();
  Future<ProductDetailsModel> fetchProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<ProductPageModel> fetchProducts(
    ProductQuery query, {
    required int skip,
  }) async {
    final category = query.category;
    final path = query.isSearching
        ? ApiEndpoints.productSearch
        : category != null
        ? ApiEndpoints.productsByCategory(category)
        : ApiEndpoints.products;

    final json = await _client.get(
      path,
      query: {
        if (query.isSearching) 'q': query.search,
        'limit': ProductQuery.pageSize,
        'skip': skip,
        'select': ProductSummaryModel.selectFields,
        ...sortParams(query.sort),
      },
    );
    return parseJson<ProductPageModel>(json, ProductPageModel.fromJson);
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final list = await _client.getList(ApiEndpoints.categories);
    try {
      return list
          .cast<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    } on Object catch (e) {
      throw ParseException(e.toString());
    }
  }

  @override
  Future<ProductDetailsModel> fetchProduct(int id) async {
    final json = await _client.get(ApiEndpoints.product(id));
    return parseJson<ProductDetailsModel>(json, ProductDetailsModel.fromJson);
  }
}

/// `sortBy` / `order` query parameters for each sort option.
Map<String, String> sortParams(ProductSort sort) => switch (sort) {
  ProductSort.relevance => const {},
  ProductSort.priceLowHigh => const {'sortBy': 'price', 'order': 'asc'},
  ProductSort.priceHighLow => const {'sortBy': 'price', 'order': 'desc'},
  ProductSort.rating => const {'sortBy': 'rating', 'order': 'desc'},
  ProductSort.titleAz => const {'sortBy': 'title', 'order': 'asc'},
};
