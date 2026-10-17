import 'dart:convert';

import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/session/user_data_cleaner.dart';
import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/features/cart/data/models/cart_models.dart';

abstract interface class CartLocalDataSource implements UserDataCleaner {
  List<CartItemModel> read();
  Future<void> write(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  const CartLocalDataSourceImpl(this._store);

  final KeyValueStore _store;

  static const _key = 'cart.items';

  @override
  List<CartItemModel> read() {
    final raw = _store.getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList();
    } on Object catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> write(List<CartItemModel> items) async {
    try {
      await _store.setString(
        _key,
        jsonEncode(items.map((i) => i.toJson()).toList()),
      );
    } on Object catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearUserData() => _store.remove(_key);
}

abstract interface class CartRemoteDataSource {
  Future<OrderModel> addCart({
    required int userId,
    required List<CartItemModel> items,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  const CartRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<OrderModel> addCart({
    required int userId,
    required List<CartItemModel> items,
  }) async {
    final json = await _client.post(
      ApiEndpoints.addCart,
      body: {
        'userId': userId,
        'products': [
          for (final item in items)
            {'id': item.product.id, 'quantity': item.quantity},
        ],
      },
    );
    return parseJson<OrderModel>(json, OrderModel.fromJson);
  }
}
