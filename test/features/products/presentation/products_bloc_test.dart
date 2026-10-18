import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';

import '../../../helpers/helpers.dart';

class _MockRepository extends Mock implements ProductRepository;

void main() {
  late _MockRepository repository;

  final firstPage = ProductPage(
    items: List.generate(20, (i) => product(id: i + 1)),
    total: 25,
    skip: 0,
  );
  final lastPage = ProductPage(
    items: List.generate(5, (i) => product(id: i + 21)),
    total: 25,
    skip: 20,
  );

  setUpAll(() => registerFallbackValue(const ProductQuery()));

  setUp(() {
    repository = _MockRepository();
    when(repository.getCategories).thenAnswer((_) async => const Ok([]));
  });

  void stubPage(ProductPage page, {int skip = 0}) =>
      when(() => repository.getProducts(any(), skip: skip))
          .thenAnswer((_) async => Ok(page));

  ProductsBloc build() => ProductsBloc(
    GetProducts(repository),
    GetCategories(repository),
    searchDebounce: const Duration(milliseconds: 50),
  );

  blocTest<ProductsBloc, ProductsState>(
    'start: loading then success',
    setUp: () => stubPage(firstPage),
    build: build,
    act: (bloc) => bloc.add(const ProductsStarted()),
    expect: () => [
      isA<ProductsState>().having(
        (s) => s.status,
        'status',
        ProductsStatus.loading,
      ),
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.success)
          .having((s) => s.items, 'items', hasLength(20))
          .having((s) => s.pagination, 'pagination', PaginationStatus.idle),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'start: an empty result is the empty state',
    setUp: () => stubPage(const ProductPage(items: [], total: 0, skip: 0)),
    build: build,
    act: (bloc) => bloc.add(const ProductsStarted()),
    skip: 1,
    expect: () => [
      isA<ProductsState>().having(
        (s) => s.status,
        'status',
        ProductsStatus.empty,
      ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'start: a failure is the error state',
    setUp: () =>
        when(() => repository.getProducts(any(), skip: 0))
            .thenAnswer((_) async => const Err(ServerFailure(statusCode: 500))),
    build: build,
    act: (bloc) => bloc.add(const ProductsStarted()),
    skip: 1,
    expect: () => [
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.failure)
          .having(
            (s) => s.failure,
            'failure',
            const ServerFailure(statusCode: 500),
          ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'next page: loadingMore, then appends and stops at the end',
    setUp: () {
      stubPage(firstPage);
      stubPage(lastPage, skip: 20);
    },
    build: build,
    act: (bloc) async {
      bloc.add(const ProductsStarted());
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(const ProductsNextPageRequested())
        // Ignored: a page is already loading (droppable).
        ..add(const ProductsNextPageRequested());
    },
    skip: 2,
    expect: () => [
      isA<ProductsState>().having(
        (s) => s.pagination,
        'pagination',
        PaginationStatus.loadingMore,
      ),
      isA<ProductsState>()
          .having((s) => s.items, 'items', hasLength(25))
          .having(
            (s) => s.pagination,
            'pagination',
            PaginationStatus.reachedEnd,
          ),
    ],
    verify: (_) =>
        verify(() => repository.getProducts(any(), skip: 20)).called(1),
  );

  blocTest<ProductsBloc, ProductsState>(
    'next page failure shows a retry footer and keeps the items',
    setUp: () {
      stubPage(firstPage);
      when(() => repository.getProducts(any(), skip: 20))
          .thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: build,
    act: (bloc) async {
      bloc.add(const ProductsStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ProductsNextPageRequested());
    },
    skip: 3,
    expect: () => [
      isA<ProductsState>()
          .having((s) => s.pagination, 'pagination', PaginationStatus.failed)
          .having((s) => s.items, 'items', hasLength(20)),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'search is debounced: fast typing makes one request',
    setUp: () => stubPage(firstPage),
    build: build,
    act: (bloc) async {
      bloc
        ..add(const ProductsSearchChanged('p'))
        ..add(const ProductsSearchChanged('ph'))
        ..add(const ProductsSearchChanged('phone'));
      await Future<void>.delayed(const Duration(milliseconds: 120));
    },
    verify: (bloc) {
      expect(bloc.state.query.search, 'phone');
      verify(() => repository.getProducts(any(), skip: 0)).called(1);
    },
  );

  blocTest<ProductsBloc, ProductsState>(
    'picking a category ends the search',
    setUp: () => stubPage(firstPage),
    build: build,
    seed: () => const ProductsState(query: ProductQuery(search: 'phone')),
    act: (bloc) => bloc.add(const ProductsCategorySelected('laptops')),
    verify: (bloc) {
      expect(bloc.state.query.search, isEmpty);
      expect(bloc.state.query.category, 'laptops');
    },
  );

  blocTest<ProductsBloc, ProductsState>(
    'a failed refresh keeps the content and reports softly',
    setUp: () =>
        when(() => repository.getProducts(any(), skip: 0))
            .thenAnswer((_) async => const Err(NetworkFailure())),
    build: build,
    seed: () => ProductsState(
      status: ProductsStatus.success,
      items: firstPage.items,
      total: 25,
      categories: const [Category(slug: 'beauty', name: 'Beauty')],
    ),
    act: (bloc) => bloc.add(ProductsRefreshed()),
    expect: () => [
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.success)
          .having((s) => s.items, 'items', hasLength(20))
          .having(
            (s) => s.refreshFailure,
            'refreshFailure',
            const NetworkFailure(),
          ),
    ],
  );
}
