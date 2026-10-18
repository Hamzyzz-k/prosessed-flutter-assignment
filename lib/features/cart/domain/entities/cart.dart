import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final ProductSummary product;
  final int quantity;

  /// Price before discount × quantity.
  double get subtotal => roundMoney(product.price * quantity);

  /// Built from the unit price the shopper sees ($8.94 × 2 = $17.88), so
  /// every number on screen adds up exactly.
  double get total => roundMoney(product.finalPrice * quantity);

  /// Money saved on this line.
  double get discount => roundMoney(subtotal - total);

  /// The most of this product the shopper can buy.
  int get maxQuantity => product.stock;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

/// The numbers at the bottom of the cart.
class CartSummary extends Equatable {
  const CartSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.itemCount,
  });

  factory CartSummary.of(List<CartItem> items) {
    var subtotal = 0.0;
    var total = 0.0;
    var count = 0;
    for (final item in items) {
      subtotal += item.subtotal;
      total += item.total;
      count += item.quantity;
    }
    // Lines are already in cents; rounding again only removes float noise.
    return CartSummary(
      subtotal: roundMoney(subtotal),
      discount: roundMoney(subtotal - total),
      total: roundMoney(total),
      itemCount: count,
    );
  }

  static const empty = CartSummary(
    subtotal: 0,
    discount: 0,
    total: 0,
    itemCount: 0,
  );

  final double subtotal;
  final double discount;
  final double total;

  /// Sum of quantities, shown on the cart badge.
  final int itemCount;

  @override
  List<Object?> get props => [subtotal, discount, total, itemCount];
}

/// What DummyJSON returns for a (simulated) order.
class OrderConfirmation extends Equatable {
  const OrderConfirmation({
    required this.id,
    required this.total,
    required this.discountedTotal,
    required this.totalQuantity,
  });

  final int id;
  final double total;
  final double discountedTotal;
  final int totalQuantity;

  double get saved => roundMoney(total - discountedTotal);

  @override
  List<Object?> get props => [id, total, discountedTotal, totalQuantity];
}
