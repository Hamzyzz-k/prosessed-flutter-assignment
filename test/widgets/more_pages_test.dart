import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/splash_page.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/pages/order_placed_page.dart';
import 'package:shopsphere/features/diagnostics/domain/entities/lab_scenario.dart';
import 'package:shopsphere/features/diagnostics/domain/repositories/diagnostics_repository.dart';
import 'package:shopsphere/features/diagnostics/presentation/cubit/error_lab_cubit.dart';
import 'package:shopsphere/features/diagnostics/presentation/pages/error_lab_page.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shopsphere/features/profile/presentation/pages/profile_page.dart';
import 'package:shopsphere/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:shopsphere/features/settings/domain/entities/app_settings.dart';
import 'package:shopsphere/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:shopsphere/features/wishlist/presentation/pages/wishlist_page.dart';

import '../helpers/helpers.dart';
import '../helpers/pump_app.dart';

class _MockWishlist extends MockCubit<List<ProductSummary>>
    implements WishlistCubit;

class _MockCart extends MockCubit<CartState> implements CartCubit;

class _MockAuth extends MockCubit<AuthState> implements AuthCubit;

class _MockAuthRepository extends Mock implements AuthRepository;

class _MockDiagnostics extends Mock implements DiagnosticsRepository;

const _user = User(
  id: 1,
  username: 'emilys',
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily@example.com',
  image: '',
  phone: '+81 965-431-3024',
  address: '626 Main Street, Phoenix',
);

void main() {
  testWidgets('SplashPage shows the brand while the session is checked', (
    tester,
  ) async {
    await tester.pumpApp(const SplashPage());

    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  group('WishlistPage', () {
    late _MockWishlist wishlist;

    setUp(() => wishlist = _MockWishlist());

    testWidgets('empty state invites shopping', (tester) async {
      when(() => wishlist.state).thenReturn(const []);

      await tester.pumpApp(
        const WishlistPage(),
        providers: [BlocProvider<WishlistCubit>.value(value: wishlist)],
      );

      expect(find.text('No favourites yet'), findsOneWidget);
    });

    testWidgets('shows saved products', (tester) async {
      when(
        () => wishlist.state,
      ).thenReturn([product(title: 'Galaxy'), product(id: 2, title: 'Pixel')]);

      await tester.pumpApp(
        const WishlistPage(),
        providers: [BlocProvider<WishlistCubit>.value(value: wishlist)],
      );

      expect(find.text('Galaxy'), findsOneWidget);
      expect(find.text('Pixel'), findsOneWidget);
    });
  });

  group('ProfilePage', () {
    late _MockAuthRepository repository;
    late _MockAuth auth;
    late SettingsCubit settings;

    setUp(() {
      repository = _MockAuthRepository();
      auth = _MockAuth();
      settings = SettingsCubit(SettingsRepositoryImpl(InMemoryKeyValueStore()));
      when(() => auth.state).thenReturn(const Authenticated(_user));
      sl.registerFactory(() => ProfileCubit(GetCurrentUser(repository)));
    });

    tearDown(sl.reset);

    Future<void> pump(WidgetTester tester) => tester.pumpApp(
      const ProfilePage(),
      size: const Size(400, 1100),
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<SettingsCubit>.value(value: settings),
      ],
    );

    testWidgets('shows the user from /auth/me', (tester) async {
      when(repository.getCurrentUser).thenAnswer((_) async => const Ok(_user));

      await pump(tester);
      await tester.pump();

      expect(find.text('Emily Johnson'), findsOneWidget);
      expect(find.text('emily@example.com'), findsOneWidget);
      expect(find.text('+81 965-431-3024'), findsOneWidget);
    });

    testWidgets('a failure offers to try again', (tester) async {
      when(repository.getCurrentUser)
          .thenAnswer((_) async => const Err(NetworkFailure()));

      await pump(tester);
      await tester.pump();

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('theme and language switches are remembered', (tester) async {
      when(repository.getCurrentUser).thenAnswer((_) async => const Ok(_user));
      await pump(tester);
      await tester.pump();

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.tap(find.text('हिन्दी'));
      await tester.pump();

      expect(settings.state.theme, ThemePreference.dark);
      expect(settings.state.language, AppLanguage.hindi);
    });

    testWidgets('logout asks first, then signs out', (tester) async {
      when(repository.getCurrentUser).thenAnswer((_) async => const Ok(_user));
      when(auth.logout).thenAnswer((_) async {});
      await pump(tester);
      await tester.pump();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Log out?'), findsOneWidget);
      verifyNever(auth.logout);

      await tester.tap(find.text('Log out').last);
      await tester.pumpAndSettle();

      verify(auth.logout).called(1);
    });

    testWidgets('cancelling the logout dialog keeps the session', (
      tester,
    ) async {
      when(repository.getCurrentUser).thenAnswer((_) async => const Ok(_user));
      await pump(tester);
      await tester.pump();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(auth.logout);
    });
  });

  group('ErrorLabPage', () {
    late _MockDiagnostics diagnostics;

    setUp(() {
      diagnostics = _MockDiagnostics();
      sl.registerFactory(() => ErrorLabCubit(diagnostics));
    });

    tearDown(sl.reset);

    testWidgets('running a scenario shows how the app handled it', (
      tester,
    ) async {
      when(() => diagnostics.run(LabScenario.serverError))
          .thenAnswer((_) async => const Err(ServerFailure(statusCode: 500)));

      await tester.pumpApp(const ErrorLabPage(), size: const Size(500, 1400));
      await tester.tap(find.text('Run').first);
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Something went wrong on our side. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('a scenario the app recovers from reports success', (
      tester,
    ) async {
      when(() => diagnostics.run(LabScenario.expiredAccessToken))
          .thenAnswer((_) async => const Ok(Duration(milliseconds: 1200)));

      await tester.pumpApp(const ErrorLabPage(), size: const Size(500, 1400));
      await tester.tap(find.text('Run').at(3));
      await tester.pump();
      await tester.pump();

      expect(find.text('Success in 1200 ms'), findsOneWidget);
    });
  });

  testWidgets('OrderPlacedPage shows the order id and what was saved', (
    tester,
  ) async {
    final cart = _MockCart();
    final items = [CartItem(product: product(), quantity: 2)];
    when(() => cart.state).thenReturn(
      CartState(
        isLoaded: true,
        checkout: CheckoutStatus.success,
        order: const OrderConfirmation(
          id: 209,
          total: 200,
          discountedTotal: 180,
          totalQuantity: 2,
        ),
        orderSummary: CartSummary.of(items),
      ),
    );

    await tester.pumpApp(
      const OrderPlacedPage(),
      providers: [BlocProvider<CartCubit>.value(value: cart)],
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Order placed!'), findsOneWidget);
    expect(
      find.text(
        'Order #209 is confirmed. This is a demo, so nothing will be shipped.',
      ),
      findsOneWidget,
    );
    expect(find.text(r'You saved $20.00'), findsOneWidget);
  });
}
