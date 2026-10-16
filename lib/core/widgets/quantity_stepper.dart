import 'package:flutter/material.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';

/// A "− 2 +" stepper with 48 dp tap targets; buttons disable at the limits.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.dense = false,
    super.key,
  });

  final int value;
  final int min;
  final int max;
  final bool dense;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final enabled = onChanged != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.decreaseQuantity,
            visualDensity: dense ? VisualDensity.compact : null,
            onPressed: enabled && value > min
                ? () => onChanged!(value - 1)
                : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
              semanticsLabel: '${l10n.quantity} $value',
            ),
          ),
          IconButton(
            tooltip: l10n.increaseQuantity,
            visualDensity: dense ? VisualDensity.compact : null,
            onPressed: enabled && value < max
                ? () => onChanged!(value + 1)
                : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
