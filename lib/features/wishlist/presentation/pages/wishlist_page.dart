import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/core/widgets/status_view.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/shop_widgets.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlistTitle)),
      body: BlocBuilder<WishlistCubit, List<ProductSummary>>(
        builder: (context, items) {
          if (items.isEmpty) {
            return EmptyView(
              icon: Icons.favorite_border_rounded,
              title: l10n.wishlistEmptyTitle,
              message: l10n.wishlistEmptyMessage,
              actionLabel: l10n.startShopping,
              actionIcon: Icons.storefront_outlined,
              onAction: () => context.go(Routes.shop),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = productGridColumns(constraints.maxWidth);
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(Insets.lg),
                    sliver: SliverGrid(
                      gridDelegate: productGridDelegate(context, columns),
                      delegate: SliverChildBuilderDelegate(
                        childCount: items.length,
                        (context, index) => ProductCard(
                          product: items[index],
                          onTap: () => unawaited(
                            context.push(
                              Routes.product(
                                items[index].id,
                                from: Routes.wishlist,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
