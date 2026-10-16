import 'package:flutter/material.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/widgets/brand_mark.dart';

/// Shown while `AuthCubit.checkSession` reads storage. The router moves on
/// by itself once the session state is known.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 96),
            Gaps.xl,
            Text(l10n.appTitle, style: theme.textTheme.headlineMedium),
            Gaps.sm,
            Text(
              l10n.splashTagline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            Gaps.xxl,
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
