import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final ProductSummary product;
  final int quantity;

  /// Price before discount × quantity.
  double get subtotal => product.price * quantity;

  /// Money saved on this line.
  double get discount => subtotal * product.discountPercentage / 100;

  double get total => subtotal - discount;

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
    var discount = 0.0;
    var count = 0;
    for (final item in items) {
      subtotal += item.subtotal;
      discount += item.discount;
      count += item.quantity;
    }
    // Round each total once, at the end, so cents never drift.
    final roundedSubtotal = roundMoney(subtotal);
    final roundedDiscount = roundMoney(discount);
    return CartSummary(
      subtotal: roundedSubtotal,
      discount: roundedDiscount,
      total: roundMoney(roundedSubtotal - roundedDiscount),
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
