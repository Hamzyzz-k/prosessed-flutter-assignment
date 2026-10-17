import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/core/widgets/brand_mark.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';

/// Tabs: bottom navigation bar on phones, navigation rail on tablets.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    // Tapping the current tab again returns it to its first page.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cartCount = context.select<CartCubit, int>(
      (c) => c.state.summary.itemCount,
    );

    final cartIcon = Semantics(
      label: l10n.cartBadgeLabel(cartCount),
      excludeSemantics: true,
      child: Badge.count(
        count: cartCount,
        isLabelVisible: cartCount > 0,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
    final cartSelectedIcon = Semantics(
      label: l10n.cartBadgeLabel(cartCount),
      excludeSemantics: true,
      child: Badge.count(
        count: cartCount,
        isLabelVisible: cartCount > 0,
        child: const Icon(Icons.shopping_cart_rounded),
      ),
    );

    final destinations = [
      (
        Icons.storefront_outlined,
        Icons.storefront_rounded,
        l10n.navShop,
        null,
        null,
      ),
      (
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
        l10n.navWishlist,
        null,
        null,
      ),
      (null, null, l10n.navCart, cartIcon, cartSelectedIcon),
      (
        Icons.person_outline_rounded,
        Icons.person_rounded,
        l10n.navProfile,
        null,
        null,
      ),
    ];

    if (context.windowSize.isCompact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onSelect,
          destinations: [
            for (final (icon, selected, label, custom, customSelected)
                in destinations)
              NavigationDestination(
                icon: custom ?? Icon(icon),
                selectedIcon: customSelected ?? Icon(selected),
                label: label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onSelect,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: BrandMark(size: 40),
            ),
            groupAlignment: -0.6,
            destinations: [
              for (final (icon, selected, label, custom, customSelected)
                  in destinations)
                NavigationRailDestination(
                  icon: custom ?? Icon(icon),
                  selectedIcon: customSelected ?? Icon(selected),
                  label: Text(label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
