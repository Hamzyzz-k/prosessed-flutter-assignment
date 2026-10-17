import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

abstract interface class CartRepository {
  /// The cart saved on this device.
  Future<Result<List<CartItem>>> loadCart();

  Future<Result<void>> saveCart(List<CartItem> items);

  /// Sends the order (`POST /carts/add`) and empties the saved cart.
  Future<Result<OrderConfirmation>> placeOrder({
    required int userId,
    required List<CartItem> items,
  });
}
