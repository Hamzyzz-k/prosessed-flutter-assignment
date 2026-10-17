import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/app_shell.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/auth/presentation/pages/splash_page.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/pages/cart_page.dart';
import 'package:shopsphere/features/cart/presentation/pages/checkout_page.dart';
import 'package:shopsphere/features/cart/presentation/pages/order_placed_page.dart';
import 'package:shopsphere/features/diagnostics/presentation/pages/error_lab_page.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_view.dart';
import 'package:shopsphere/features/products/presentation/pages/shop_page.dart';
import 'package:shopsphere/features/profile/presentation/pages/profile_page.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:shopsphere/features/wishlist/presentation/pages/wishlist_page.dart';

/// Builds the app's routes. Navigation on login/logout is never done by
/// hand: [_redirect] reacts to [AuthCubit] and sends the user where they
/// belong.
GoRouter createRouter(AuthCubit auth) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _StreamListenable(auth.stream),
    redirect: (context, state) => _redirect(auth.state, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginPage(),
        ),
      ),
      // Everything below only exists while signed in. When the user logs
      // out this scope is disposed, taking the cart and wishlist with it.
      ShellRoute(
        builder: (_, _, child) => _SignedInScope(child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (_, _, shell) => AppShell(navigationShell: shell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: Routes.shop,
                    builder: (_, _) => BlocProvider(
                      create: (_) =>
                          sl<ProductsBloc>()..add(const ProductsStarted()),
                      child: const ShopPage(),
                    ),
                    routes: [_productRoute()],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: Routes.wishlist,
                    builder: (_, _) => const WishlistPage(),
                    routes: [_productRoute()],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: Routes.cart,
                    builder: (_, _) => const CartPage(),
                    routes: [_productRoute()],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: Routes.profile,
                    builder: (_, _) => const ProfilePage(),
                    routes: [
                      GoRoute(
                        path: 'error-lab',
                        builder: (_, _) => const ErrorLabPage(),
                      ),
                      _productRoute(),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.checkout,
            builder: (_, _) => const CheckoutPage(),
          ),
          GoRoute(
            path: Routes.orderPlaced,
            builder: (_, _) => const OrderPlacedPage(),
          ),
        ],
      ),
    ],
  );
}

GoRoute _productRoute() => GoRoute(
  path: 'product/:id',
  builder: (_, state) => ProductDetailsPage(
    // A non-numeric id can never exist, so treat it like a 404.
    productId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
  ),
);

String? _redirect(AuthState auth, String location) {
  final atSplash = location == Routes.splash;
  final atLogin = location == Routes.login;
  return switch (auth) {
    AuthUnknown() => atSplash ? null : Routes.splash,
    Unauthenticated() => atLogin ? null : Routes.login,
    Authenticated() => atSplash || atLogin ? Routes.shop : null,
  };
}

/// Cubits that belong to the signed-in user.
class _SignedInScope extends StatelessWidget {
  const _SignedInScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cart = sl<CartCubit>();
            unawaited(cart.load());
            return cart;
          },
        ),
        BlocProvider(
          create: (_) {
            final wishlist = sl<WishlistCubit>();
            unawaited(wishlist.load());
            return wishlist;
          },
        ),
      ],
      child: child,
    );
  }
}

/// Lets go_router re-run its redirect whenever a stream emits.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
