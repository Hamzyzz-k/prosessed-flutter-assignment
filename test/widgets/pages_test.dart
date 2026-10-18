import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/connectivity/connectivity_cubit.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/pages/cart_page.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_view.dart';
import 'package:shopsphere/features/products/presentation/pages/shop_page.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';

import '../helpers/helpers.dart';
import '../helpers/pump_app.dart';

class _MockProductsBloc extends MockBloc<ProductsEvent, ProductsState>
    implements ProductsBloc;

class _MockConnectivity extends MockCubit<bool> implements ConnectivityCubit;

class _MockWishlist extends MockCubit<List<ProductSummary>>
    implements WishlistCubit;

class _MockCart extends MockCubit<CartState> implements CartCubit;

class _MockRepository extends Mock implements ProductRepository;

void main() {
  late _MockProductsBloc products;
  late _MockConnectivity connectivity;
  late _MockWishlist wishlist;
  late _MockCart cart;

  setUpAll(() {
    registerFallbackValue(ProductsRefreshed());
    registerFallbackValue(product());
  });

  setUp(() {
    products = _MockProductsBloc();
    connectivity = _MockConnectivity();
    wishlist = _MockWishlist();
    cart = _MockCart();
    when(() => connectivity.state).thenReturn(true);
    when(() => wishlist.state).thenReturn(const []);
    when(() => cart.state).thenReturn(const CartState(isLoaded: true));
  });

  List<BlocProvider> providers() => [
    BlocProvider<ProductsBloc>.value(value: products),
    BlocProvider<ConnectivityCubit>.value(value: connectivity),
    BlocProvider<WishlistCubit>.value(value: wishlist),
    BlocProvider<CartCubit>.value(value: cart),
  ];

  group('ShopPage', () {
    testWidgets('shows products, categories and the end of the list', (
      tester,
    ) async {
      when(() => products.state).thenReturn(
        ProductsState(
          status: ProductsStatus.success,
          pagination: PaginationStatus.reachedEnd,
          items: [
            product(title: 'Galaxy'),
            product(id: 2, title: 'Pixel'),
          ],
          total: 2,
          categories: const [Category(slug: 'beauty', name: 'Beauty')],
        ),
      );

      await tester.pumpApp(const ShopPage(), providers: providers());

      expect(find.text('Galaxy'), findsOneWidget);
      expect(find.text('Pixel'), findsOneWidget);
      expect(find.text('Beauty'), findsOneWidget);
      expect(find.text("That's everything for now."), findsOneWidget);
    });

    testWidgets('typing searches and tapping a chip filters', (tester) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.success,
          categories: [Category(slug: 'beauty', name: 'Beauty')],
        ),
      );
      await tester.pumpApp(const ShopPage(), providers: providers());

      await tester.enterText(find.byType(TextField), 'phone');
      await tester.tap(find.text('Beauty'));

      verify(() => products.add(const ProductsSearchChanged('phone')));
      verify(() => products.add(const ProductsCategorySelected('beauty')));
    });

    testWidgets('empty results offer to clear filters', (tester) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.empty,
          query: ProductQuery(search: 'zzzz'),
        ),
      );
      await tester.pumpApp(const ShopPage(), providers: providers());

      expect(find.text('No products found'), findsOneWidget);
      expect(find.text('Results for "zzzz"'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      verify(() => products.add(const ProductsFiltersCleared()));
    });

    testWidgets('a failure shows the error with retry', (tester) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.failure,
          failure: ServerFailure(statusCode: 500),
        ),
      );
      await tester.pumpApp(const ShopPage(), providers: providers());

      expect(
        find.text('Something went wrong on our side. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Try again'));
      verify(() => products.add(any(that: isA<ProductsRefreshed>())));
    });

    testWidgets('offline with saved products shows the banner', (tester) async {
      when(() => connectivity.state).thenReturn(false);
      when(() => products.state).thenReturn(
        ProductsState(
          status: ProductsStatus.success,
          items: [product()],
          isFromCache: true,
        ),
      );
      await tester.pumpApp(const ShopPage(), providers: providers());

      expect(
        find.text('You are offline · showing saved products'),
        findsOneWidget,
      );
    });

    testWidgets('a tablet in landscape shows master–detail', (tester) async {
      when(() => products.state).thenReturn(
        ProductsState(status: ProductsStatus.success, items: [product()]),
      );
      await tester.pumpApp(
        const ShopPage(),
        providers: providers(),
        size: const Size(1280, 800),
      );

      expect(
        find.text('Pick a product to see its details here.'),
        findsOneWidget,
      );
    });
  });

  group('ProductDetailsView', () {
    late _MockRepository repository;

    setUp(() {
      repository = _MockRepository();
      sl.registerFactoryParam<ProductDetailsCubit, int, void>(
        (id, _) => ProductDetailsCubit(GetProductDetails(repository), id),
      );
    });

    tearDown(sl.reset);

    testWidgets('shows details and adds to cart', (tester) async {
      when(() => repository.getProduct(1)).thenAnswer(
        (_) async => const Ok(
          ProductDetails(
            id: 1,
            title: 'Galaxy S8',
            price: 500,
            discountPercentage: 20,
            rating: 4.4,
            stock: 3,
            thumbnail: '',
            category: 'smartphones',
            brand: 'Samsung',
            description: 'A great phone.',
            images: [],
            reviews: [
              Review(rating: 5, comment: 'Love it', reviewerName: 'Ana'),
            ],
            shipping: 'Ships in 2 days',
          ),
        ),
      );
      when(() => cart.add(any(), quantity: any(named: 'quantity')))
          .thenAnswer((_) async {});

      await tester.pumpApp(
        ProductDetailsView(productId: 1, onBack: () {}),
        providers: providers(),
      );
      await tester.pump();

      expect(find.text('Galaxy S8'), findsOneWidget);
      expect(find.text('by Samsung'), findsOneWidget);
      expect(find.text('Only 3 left'), findsOneWidget);
      expect(find.text('Love it'), findsOneWidget);

      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();
      await tester.tap(find.text('Add to cart'));
      await tester.pump();

      verify(() => cart.add(any(), quantity: 2)).called(1);
      expect(find.text('Added to cart'), findsOneWidget);
    });

    testWidgets('unknown product shows "Product not found"', (tester) async {
      var wentBack = false;
      when(() => repository.getProduct(9999))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      await tester.pumpApp(
        ProductDetailsView(productId: 9999, onBack: () => wentBack = true),
        providers: providers(),
      );
      await tester.pump();

      expect(find.text('Product not found'), findsOneWidget);
      await tester.tap(find.text('Back to shop'));
      expect(wentBack, isTrue);
    });

    testWidgets('out of stock disables add to cart', (tester) async {
      when(() => repository.getProduct(1)).thenAnswer(
        (_) async => const Ok(
          ProductDetails(
            id: 1,
            title: 'Sold out',
            price: 10,
            discountPercentage: 0,
            rating: 3,
            stock: 0,
            thumbnail: '',
            category: 'x',
            description: '',
            images: [],
            reviews: [],
          ),
        ),
      );

      await tester.pumpApp(
        ProductDetailsView(productId: 1, onBack: () {}),
        providers: providers(),
      );
      await tester.pump();

      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Out of stock').last,
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('CartPage', () {
    testWidgets('empty cart invites shopping', (tester) async {
      await tester.pumpApp(const CartPage(), providers: providers());

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('lists items with totals and supports remove', (tester) async {
      final items = [CartItem(product: product(title: 'Galaxy'), quantity: 2)];
      when(() => cart.state).thenReturn(
        CartState(items: items, summary: CartSummary.of(items), isLoaded: true),
      );
      when(() => cart.remove(1)).thenAnswer((_) async {});

      await tester.pumpApp(const CartPage(), providers: providers());

      expect(find.text('Galaxy'), findsOneWidget);
      expect(find.text(r'$200.00'), findsOneWidget);
      expect(find.text(r'− $20.00'), findsOneWidget);
      expect(find.text(r'$180.00'), findsWidgets);

      await tester.tap(find.byTooltip('Remove'));
      await tester.pump();
      verify(() => cart.remove(1)).called(1);
      expect(find.text('Galaxy removed'), findsOneWidget);
    });
  });
}
