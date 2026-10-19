import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_widgets.dart';

/// A short review before the order is placed.
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = switch (context.watch<AuthCubit>().state) {
      Authenticated(:final user) => user,
      _ => null,
    };

    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (a, b) => a.checkout != b.checkout,
      listener: (context, state) {
        if (state.checkout == CheckoutStatus.success) {
          context.go(Routes.orderPlaced);
        } else if (state.checkout == CheckoutStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.failure!.describe(l10n))),
            );
        }
      },
      builder: (context, state) {
        final placing = state.checkout == CheckoutStatus.placing;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.checkoutTitle)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(Insets.lg),
                children: [
                  _Section(
                    icon: Icons.location_on_outlined,
                    title: l10n.deliverTo,
                    child: Text(
                      [
                        user?.fullName,
                        user?.address,
                      ].whereType<String>().join('\n'),
                    ),
                  ),
                  _Section(
                    icon: Icons.payments_outlined,
                    title: l10n.payment,
                    child: Text(l10n.cashOnDelivery),
                  ),
                  _Section(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.orderSummary,
                    child: Column(
                      children: [
                        for (final item in state.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Insets.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.title} × ${item.quantity}',
                                  ),
                                ),
                                Gaps.md,
                                Text(Formatters.price(item.total)),
                              ],
                            ),
                          ),
                        const Divider(height: Insets.xl),
                        CartTotals(summary: state.summary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Material(
            color: theme.colorScheme.surfaceContainer,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(Insets.lg),
                child: FilledButton(
                  onPressed: placing || user == null || state.isEmpty
                      ? null
                      : () => unawaited(
                          context.read<CartCubit>().placeOrder(userId: user.id),
                        ),
                  child: placing
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          '${l10n.placeOrder} · '
                          '${Formatters.price(state.summary.total)}',
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  Gaps.sm,
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              Gaps.md,
              child,
            ],
          ),
        ),
      ),
    );
  }
}
