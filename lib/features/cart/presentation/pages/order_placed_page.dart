import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_palette.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';

class OrderPlacedPage extends StatelessWidget {
  const OrderPlacedPage({super.key});

  void _continue(BuildContext context) {
    context.read<CartCubit>().acknowledgeOrder();
    context.go(Routes.shop);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final order = context.select<CartCubit, OrderConfirmation?>(
      (c) => c.state.order,
    );
    final saved = context.select<CartCubit, double>(
      (c) => c.state.orderSummary?.discount ?? 0,
    );
    final palette = context.palette;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _continue(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Insets.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.4, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Insets.xl),
                          child: Icon(
                            Icons.check_rounded,
                            size: 64,
                            color: palette.success,
                          ),
                        ),
                      ),
                    ),
                    Gaps.xl,
                    Text(
                      l10n.orderPlacedTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (order != null) ...[
                      Gaps.sm,
                      Text(
                        l10n.orderPlacedMessage(order.id),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (saved > 0) ...[
                        Gaps.lg,
                        Chip(
                          avatar: Icon(
                            Icons.savings_outlined,
                            color: palette.success,
                          ),
                          label: Text(l10n.youSaved(Formatters.price(saved))),
                        ),
                      ],
                    ],
                    Gaps.xxl,
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _continue(context),
                        icon: const Icon(Icons.storefront_outlined),
                        label: Text(l10n.continueShopping),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
