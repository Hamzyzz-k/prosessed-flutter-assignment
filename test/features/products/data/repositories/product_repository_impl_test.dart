import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

import '../../../../helpers/helpers.dart';

class _MockRemote extends Mock implements ProductRemoteDataSource;

void main() {
  late _MockRemote remote;
  late ProductLocalDataSourceImpl local;
  late ProductRepositoryImpl repository;
  final page = ProductPageModel.fromJson(fixture('products_page.json'));

  setUpAll(() => registerFallbackValue(const ProductQuery()));

  setUp(() {
    remote = _MockRemote();
    local = ProductLocalDataSourceImpl(InMemoryKeyValueStore());
    repository = ProductRepositoryImpl(remote, local);
  });

  group('getProducts', () {
    test('returns the page and caches the default first page', () async {
      when(() => remote.fetchProducts(any(), skip: 0))
          .thenAnswer((_) async => page);

      final result = await repository.getProducts(
        const ProductQuery(),
        skip: 0,
      );

      expect(result.valueOrNull?.items, hasLength(2));
      expect(local.readFirstPage(), isNotNull);
    });

    test('does not cache searches', () async {
      when(() => remote.fetchProducts(any(), skip: 0))
          .thenAnswer((_) async => page);

      await repository.getProducts(
        const ProductQuery(search: 'phone'),
        skip: 0,
      );

      expect(local.readFirstPage(), isNull);
    });

    test('maps a server error to ServerFailure', () async {
      when(() => remote.fetchProducts(any(), skip: 0))
          .thenThrow(const ServerException(statusCode: 500));

      final result = await repository.getProducts(
        const ProductQuery(),
        skip: 0,
      );

      expect(result, const Err<ProductPage>(ServerFailure(statusCode: 500)));
    });

    test('offline with a cache returns the saved page', () async {
      await local.cacheFirstPage(page);
      when(() => remote.fetchProducts(any(), skip: 0))
          .thenThrow(const NetworkException());

      final result = await repository.getProducts(
        const ProductQuery(),
        skip: 0,
      );

      expect(result.valueOrNull?.isFromCache, isTrue);
      expect(result.valueOrNull?.hasMore, isFalse);
    });

    test('offline without a cache returns NetworkFailure', () async {
      when(() => remote.fetchProducts(any(), skip: 20))
          .thenThrow(const NetworkException());

      final result = await repository.getProducts(
        const ProductQuery(),
        skip: 20,
      );

      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  test('getProduct maps 404 to NotFoundFailure', () async {
    when(() => remote.fetchProduct(9999))
        .thenThrow(const NotFoundException("Product with id '9999' not found"));

    final result = await repository.getProduct(9999);

    expect(result.failureOrNull, isA<NotFoundFailure>());
  });
}
