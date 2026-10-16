import 'package:flutter/material.dart';

/// The ShopSphere logo: a soft gradient sphere holding a shopping bag.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.tertiary],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.25),
              blurRadius: size / 4,
              offset: Offset(0, size / 12),
            ),
          ],
        ),
        child: Icon(
          Icons.shopping_bag_rounded,
          size: size * 0.48,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}
