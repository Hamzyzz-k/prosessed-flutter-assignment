import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

import '../../../../helpers/helpers.dart';

class _MockClient extends Mock implements ApiClient;

void main() {
  late _MockClient client;
  late ProductRemoteDataSourceImpl dataSource;

  setUp(() {
    client = _MockClient();
    dataSource = ProductRemoteDataSourceImpl(client);
    when(() => client.get(any(), query: any(named: 'query')))
        .thenAnswer((_) async => fixture('products_page.json'));
  });

  Map<String, dynamic> capturedQuery(String path) {
    return verify(() => client.get(path, query: captureAny(named: 'query')))
            .captured
            .single
        as Map<String, dynamic>;
  }

  test('default list uses /products with paging and select', () async {
    await dataSource.fetchProducts(const ProductQuery(), skip: 20);

    final query = capturedQuery('/products');
    expect(query['limit'], 20);
    expect(query['skip'], 20);
    expect(query['select'], contains('thumbnail'));
    expect(query.containsKey('sortBy'), isFalse);
  });

  test('search uses /products/search with q', () async {
    await dataSource.fetchProducts(
      const ProductQuery(search: 'phone', sort: ProductSort.priceLowHigh),
      skip: 0,
    );

    final query = capturedQuery('/products/search');
    expect(query['q'], 'phone');
    expect(query['sortBy'], 'price');
    expect(query['order'], 'asc');
  });

  test('category uses /products/category/{slug}', () async {
    await dataSource.fetchProducts(
      const ProductQuery(category: 'smartphones', sort: ProductSort.rating),
      skip: 0,
    );

    final query = capturedQuery('/products/category/smartphones');
    expect(query['sortBy'], 'rating');
    expect(query['order'], 'desc');
  });
}
