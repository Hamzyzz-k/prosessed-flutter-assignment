import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';

/// The ShopSphere logo: a soft gradient sphere holding a shopping bag.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.brandGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.seed.withValues(alpha: 0.25),
              blurRadius: size / 4,
              offset: Offset(0, size / 12),
            ),
          ],
        ),
        child: Icon(
          Icons.shopping_bag_rounded,
          size: size * 0.48,
          color: Colors.white,
        ),
      ),
    );
  }
}
