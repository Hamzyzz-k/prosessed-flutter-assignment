import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';

class _MockProductRepository extends Mock implements ProductRepository;

void main() {
  setUpAll(() => registerFallbackValue(const ProductQuery()));

  group('GetProducts', () {
    test('a search drops the category (API cannot combine them)', () async {
      final repository = _MockProductRepository();
      when(() => repository.getProducts(any(), skip: any(named: 'skip')))
          .thenAnswer(
            (_) async => const Ok(ProductPage(items: [], total: 0, skip: 0)),
          );

      await GetProducts(repository)(
        const ProductQuery(
          search: ' phone ',
          category: 'laptops',
          sort: ProductSort.rating,
        ),
      );

      verify(
        () => repository.getProducts(
          const ProductQuery(search: 'phone', sort: ProductSort.rating),
          skip: 0,
        ),
      ).called(1);
    });
  });
}
