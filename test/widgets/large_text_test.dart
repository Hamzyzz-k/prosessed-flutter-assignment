import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/connectivity/connectivity_cubit.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/pages/cart_page.dart';
import 'package:shopsphere/features/cart/presentation/pages/checkout_page.dart';
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

class _MockLogin extends MockCubit<LoginState> implements LoginCubit;

class _MockAuth extends MockCubit<AuthState> implements AuthCubit;

class _MockRepository extends Mock implements ProductRepository;

/// The brief: no overflow in any orientation or with the system font scaled
/// to 1.3x. These run the real screens on a small phone (360 x 640 dp) and
/// in landscape, and fail on any RenderFlex overflow.
void main() {
  const smallPhone = Size(360, 640);
  const phoneLandscape = Size(800, 360);
  const scale = 1.3;

  final products = [
    for (var i = 1; i <= 6; i++)
      product(
        id: i,
        title: 'A fairly long product name number $i',
        price: 1234.5,
      ),
  ];
  final items = [
    CartItem(
      product: product(title: 'Galaxy S8 with a long name'),
      quantity: 2,
    ),
    CartItem(product: product(id: 2, title: 'Another phone'), quantity: 1),
  ];

  late _MockProductsBloc productsBloc;
  late _MockCart cart;
  late _MockWishlist wishlist;
  late _MockConnectivity connectivity;

  setUp(() {
    productsBloc = _MockProductsBloc();
    cart = _MockCart();
    wishlist = _MockWishlist();
    connectivity = _MockConnectivity();
    when(() => productsBloc.state).thenReturn(
      ProductsState(
        status: ProductsStatus.success,
        items: products,
        total: 6,
        pagination: PaginationStatus.reachedEnd,
        categories: const [
          Category(slug: 'kitchen-accessories', name: 'Kitchen Accessories'),
          Category(slug: 'beauty', name: 'Beauty'),
        ],
      ),
    );
    when(() => cart.state).thenReturn(
      CartState(items: items, summary: CartSummary.of(items), isLoaded: true),
    );
    when(() => wishlist.state).thenReturn(const []);
    when(() => connectivity.state).thenReturn(true);
  });

  List<BlocProvider> providers() => [
    BlocProvider<ProductsBloc>.value(value: productsBloc),
    BlocProvider<CartCubit>.value(value: cart),
    BlocProvider<WishlistCubit>.value(value: wishlist),
    BlocProvider<ConnectivityCubit>.value(value: connectivity),
  ];

  for (final size in [smallPhone, phoneLandscape]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('shop has no overflow at 1.3x text ($label)', (tester) async {
      await tester.pumpApp(
        const ShopPage(),
        providers: providers(),
        size: size,
        textScale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('cart has no overflow at 1.3x text ($label)', (tester) async {
      await tester.pumpApp(
        const CartPage(),
        providers: providers(),
        size: size,
        textScale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkout has no overflow at 1.3x text ($label)', (
      tester,
    ) async {
      final auth = _MockAuth();
      when(() => auth.state).thenReturn(const Unauthenticated());
      await tester.pumpApp(
        const CheckoutPage(),
        providers: [
          ...providers(),
          BlocProvider<AuthCubit>.value(value: auth),
        ],
        size: size,
        textScale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('login has no overflow at 1.3x text ($label)', (tester) async {
      final login = _MockLogin();
      final auth = _MockAuth();
      when(() => login.state).thenReturn(const LoginState());
      when(() => auth.state).thenReturn(const Unauthenticated());
      await tester.pumpApp(
        const LoginPage(),
        providers: [
          BlocProvider<LoginCubit>.value(value: login),
          BlocProvider<AuthCubit>.value(value: auth),
        ],
        size: size,
        textScale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('details has no overflow at 1.3x text ($label)', (
      tester,
    ) async {
      final repository = _MockRepository();
      when(() => repository.getProduct(1)).thenAnswer(
        (_) async => Ok(
          ProductDetails(
            id: 1,
            title: 'A product with a rather long descriptive title',
            price: 1299.99,
            discountPercentage: 12.5,
            rating: 4.3,
            stock: 3,
            thumbnail: '',
            category: 'laptops',
            brand: 'Some Long Brand Name',
            description: 'A long description. ' * 12,
            images: const [],
            reviews: const [
              Review(
                rating: 4,
                comment: 'A review comment that is long enough to wrap.',
                reviewerName: 'Eleanor Collins',
              ),
            ],
            shipping: 'Ships in 3-5 business days',
          ),
        ),
      );
      sl.registerFactoryParam<ProductDetailsCubit, int, void>(
        (id, _) => ProductDetailsCubit(GetProductDetails(repository), id),
      );
      addTearDown(sl.reset);

      await tester.pumpApp(
        ProductDetailsView(productId: 1, onBack: () {}),
        providers: providers(),
        size: size,
        textScale: scale,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
