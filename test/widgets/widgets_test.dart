import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';
import 'package:shopsphere/core/widgets/status_view.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/shop_widgets.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';

import '../helpers/helpers.dart';
import '../helpers/pump_app.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit;

class _MockWishlistCubit extends MockCubit<List<ProductSummary>>
    implements WishlistCubit;

void main() {
  group('LoginPage', () {
    late _MockLoginCubit login;
    late _MockAuthCubit auth;

    setUp(() {
      login = _MockLoginCubit();
      auth = _MockAuthCubit();
      when(() => login.state).thenReturn(const LoginState());
      when(() => auth.state).thenReturn(const Unauthenticated());
    });

    Future<void> pump(WidgetTester tester) => tester.pumpApp(
      const LoginPage(),
      providers: [
        BlocProvider<LoginCubit>.value(value: login),
        BlocProvider<AuthCubit>.value(value: auth),
      ],
    );

    testWidgets('shows inline errors and does not submit empty fields', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Enter your username'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      verifyNever(
        () => login.submit(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('demo account fills the form and submits', (tester) async {
      when(
        () => login.submit(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
      await pump(tester);

      await tester.tap(find.text('Use demo account'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      verify(() => login.submit(username: 'emilys', password: 'emilyspass'))
          .called(1);
    });

    testWidgets('explains an expired session', (tester) async {
      when(() => auth.state)
          .thenReturn(const Unauthenticated(sessionExpired: true));
      await pump(tester);

      expect(
        find.text('Your session expired. Please sign in again.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('ErrorView explains the failure and retries', (tester) async {
    var retried = 0;
    await tester.pumpApp(
      ErrorView(failure: const NetworkFailure(), onRetry: () => retried++),
    );

    expect(find.text("You're offline"), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });

  testWidgets('QuantityStepper disables at its limits', (tester) async {
    int? changed;
    await tester.pumpApp(
      QuantityStepper(value: 1, max: 2, onChanged: (v) => changed = v),
    );

    await tester.tap(find.byTooltip('Decrease quantity'));
    expect(changed, isNull);
    await tester.tap(find.byTooltip('Increase quantity'));
    expect(changed, 2);
  });

  group('ProductCard', () {
    late _MockWishlistCubit wishlist;

    setUp(() {
      wishlist = _MockWishlistCubit();
      when(() => wishlist.state).thenReturn(const []);
    });

    Future<void> pumpGrid(WidgetTester tester, {double textScale = 1}) {
      return tester.pumpApp(
        Builder(
          // The real shop grid delegate, so this test checks what ships.
          builder: (context) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: productGridDelegate(context, 2),
                  delegate: SliverChildListDelegate([
                    ProductCard(
                      product: product(title: 'A rather long product title'),
                      onTap: () {},
                    ),
                    ProductCard(
                      product: product(id: 2, stock: 0),
                      onTap: () {},
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        providers: [BlocProvider<WishlistCubit>.value(value: wishlist)],
        textScale: textScale,
      );
    }

    testWidgets('shows price, discount and out-of-stock label', (tester) async {
      await pumpGrid(tester);

      expect(find.text(r'$90.00'), findsNWidgets(2));
      expect(find.text('-10%'), findsNWidgets(2));
      expect(find.text('Out of stock'), findsOneWidget);
    });

    testWidgets('does not overflow at 1.3x text size', (tester) async {
      await pumpGrid(tester, textScale: 1.3);

      expect(tester.takeException(), isNull);
    });

    testWidgets('golden: product card', tags: ['golden'], (tester) async {
      await pumpGrid(tester);

      await expectLater(
        find.byType(CustomScrollView),
        matchesGoldenFile('goldens/product_card.png'),
      );
    });
  });
}
