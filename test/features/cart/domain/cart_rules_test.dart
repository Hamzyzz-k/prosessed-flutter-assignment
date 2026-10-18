import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('CartSummary', () {
    test('adds up subtotal, discount and total', () {
      final summary = const CalculateCartSummary()([
        CartItem(product: product(), quantity: 2),
        CartItem(
          product: product(id: 2, price: 9.99, discount: 0),
          quantity: 1,
        ),
      ]);

      expect(summary.subtotal, 209.99);
      expect(summary.discount, 20);
      expect(summary.total, 189.99);
      expect(summary.itemCount, 3);
    });

    test('an empty cart is all zeros', () {
      expect(const CalculateCartSummary()(const []), CartSummary.empty);
    });

    test('rounds to cents once, at the end', () {
      final summary = CartSummary.of([
        CartItem(product: product(price: 9.99, discount: 10.48), quantity: 3),
      ]);

      expect(summary.subtotal, 29.97);
      expect(summary.discount, 3.14);
      expect(summary.total, 26.83);
    });
  });

  group('CartRules', () {
    test('adding the same product merges into one line', () {
      final once = CartRules.add(const [], product(), 1);
      final twice = CartRules.add(once, product(), 2);

      expect(twice, hasLength(1));
      expect(twice.single.quantity, 3);
    });

    test('quantity never goes above stock', () {
      final items = CartRules.add(const [], product(stock: 3), 10);

      expect(items.single.quantity, 3);
      expect(CartRules.setQuantity(items, 1, 99).single.quantity, 3);
    });

    test('quantity never goes below 1', () {
      final items = CartRules.add(const [], product(), 2);

      expect(CartRules.setQuantity(items, 1, 0).single.quantity, 1);
      expect(CartRules.setQuantity(items, 1, -5).single.quantity, 1);
    });

    test('out-of-stock products cannot be added', () {
      expect(CartRules.add(const [], product(stock: 0), 1), isEmpty);
    });

    test('remove drops only that product', () {
      final items = CartRules.add(
        CartRules.add(const [], product(), 1),
        product(id: 2),
        1,
      );

      expect(CartRules.remove(items, 1).single.product.id, 2);
    });
  });
}
