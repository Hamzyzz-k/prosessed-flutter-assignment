import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/widgets/status_view.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_widgets.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _remove(BuildContext context, CartItem item) {
    final cart = context.read<CartCubit>();
    unawaited(cart.remove(item.product.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.itemRemoved(item.product.title)),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () => unawaited(cart.undoRemove()),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cartTitle)),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isEmpty) {
            return EmptyView(
              icon: Icons.shopping_cart_outlined,
              title: l10n.cartEmptyTitle,
              message: l10n.cartEmptyMessage,
              actionLabel: l10n.startShopping,
              actionIcon: Icons.storefront_outlined,
              onAction: () => context.go(Routes.shop),
            );
          }

          final list = ListView.separated(
            padding: const EdgeInsets.all(Insets.lg),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => Gaps.md,
            itemBuilder: (context, index) {
              final item = state.items[index];
              // Swipe to delete, with a visible delete button too (swipes
              // aren't discoverable or accessible on their own).
              return Dismissible(
                key: ValueKey(item.product.id),
                direction: DismissDirection.endToStart,
                background: const _DeleteBackground(),
                onDismissed: (_) => _remove(context, item),
                child: CartLineTile(
                  item: item,
                  onTap: () => context.push(
                    Routes.product(item.product.id, from: Routes.cart),
                  ),
                  onRemove: () => _remove(context, item),
                  onQuantityChanged: (q) => unawaited(
                    context.read<CartCubit>().setQuantity(item.product.id, q),
                  ),
                ),
              );
            },
          );

          final summary = _SummaryPanel(summary: state.summary);

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 840) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: list),
                    SizedBox(
                      width: 360,
                      child: Padding(
                        padding: const EdgeInsets.all(Insets.lg),
                        child: Card(child: summary),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(child: list),
                  Material(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: SafeArea(top: false, child: summary),
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

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CartTotals(summary: summary),
          Gaps.md,
          FilledButton.icon(
            onPressed: () => context.push(Routes.checkout),
            icon: const Icon(Icons.lock_outline_rounded),
            label: Text(
              '${l10n.checkout} · ${l10n.itemCount(summary.itemCount)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: Insets.xl),
          child: Icon(
            Icons.delete_outline_rounded,
            color: scheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
