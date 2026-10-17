import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_data_sources.dart';
import 'package:shopsphere/features/cart/data/models/cart_models.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._local, this._remote);

  final CartLocalDataSource _local;
  final CartRemoteDataSource _remote;

  @override
  Future<Result<List<CartItem>>> loadCart() {
    return guard(() async => _local.read().map((m) => m.toEntity()).toList());
  }

  @override
  Future<Result<void>> saveCart(List<CartItem> items) {
    return guard(
      () => _local.write(items.map(CartItemModel.fromEntity).toList()),
    );
  }

  @override
  Future<Result<OrderConfirmation>> placeOrder({
    required int userId,
    required List<CartItem> items,
  }) {
    return guard(() async {
      final order = await _remote.addCart(
        userId: userId,
        items: items.map(CartItemModel.fromEntity).toList(),
      );
      await _local.clearUserData();
      return order.toEntity();
    });
  }
}
