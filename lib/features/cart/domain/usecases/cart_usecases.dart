import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Pure cart rules: adding, changing and removing lines.
///
/// Kept apart from the cubit so the maths is trivially unit-testable.
abstract final class CartRules {
  /// Adds [quantity] of [product]; merges with an existing line and never
  /// goes above the stock.
  static List<CartItem> add(
    List<CartItem> items,
    ProductSummary product,
    int quantity,
  ) {
    if (!product.inStock || quantity < 1) return items;
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index == -1) {
      return [
        ...items,
        CartItem(product: product, quantity: quantity.clamp(1, product.stock)),
      ];
    }
    final existing = items[index];
    final updated = existing.copyWith(
      quantity: (existing.quantity + quantity).clamp(1, product.stock),
    );
    return [...items]..[index] = updated;
  }

  /// Sets a line's quantity, kept within 1…stock.
  static List<CartItem> setQuantity(
    List<CartItem> items,
    int productId,
    int quantity,
  ) {
    return [
      for (final item in items)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity.clamp(1, item.maxQuantity))
        else
          item,
    ];
  }

  static List<CartItem> remove(List<CartItem> items, int productId) =>
      items.where((i) => i.product.id != productId).toList();
}

class LoadCart {
  const LoadCart(this._repository);

  final CartRepository _repository;

  Future<Result<List<CartItem>>> call() => _repository.loadCart();
}

class SaveCart {
  const SaveCart(this._repository);

  final CartRepository _repository;

  Future<Result<void>> call(List<CartItem> items) =>
      _repository.saveCart(items);
}

class CalculateCartSummary {
  const CalculateCartSummary();

  CartSummary call(List<CartItem> items) => CartSummary.of(items);
}

class PlaceOrder {
  const PlaceOrder(this._repository);

  final CartRepository _repository;

  Future<Result<OrderConfirmation>> call({
    required int userId,
    required List<CartItem> items,
  }) async {
    if (items.isEmpty) return const Err(UnexpectedFailure('Cart is empty'));
    return await _repository.placeOrder(userId: userId, items: items);
  }
}
