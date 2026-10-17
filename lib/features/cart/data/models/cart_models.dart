import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';

class CartItemModel {
  const CartItemModel({required this.product, required this.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    product: ProductSummaryModel.fromJson(
      json['product'] as Map<String, dynamic>,
    ),
    quantity: json['quantity'] as int,
  );

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
    product: ProductSummaryModel.fromEntity(item.product),
    quantity: item.quantity,
  );

  final ProductSummaryModel product;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  CartItem toEntity() =>
      CartItem(product: product.toEntity(), quantity: quantity);
}

/// Response of `POST /carts/add`.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.total,
    required this.discountedTotal,
    required this.totalQuantity,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as int,
    total: (json['total'] as num).toDouble(),
    discountedTotal: (json['discountedTotal'] as num).toDouble(),
    totalQuantity: json['totalQuantity'] as int,
  );

  final int id;
  final double total;
  final double discountedTotal;
  final int totalQuantity;

  OrderConfirmation toEntity() => OrderConfirmation(
    id: id,
    total: total,
    discountedTotal: discountedTotal,
    totalQuantity: totalQuantity,
  );
}
