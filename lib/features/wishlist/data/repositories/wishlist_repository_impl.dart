import 'dart:convert';

import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/session/user_data_cleaner.dart';
import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/domain/repositories/wishlist_repository.dart';

/// The wishlist has no API, so the repository talks to storage directly.
class WishlistRepositoryImpl implements WishlistRepository, UserDataCleaner {
  const WishlistRepositoryImpl(this._store);

  final KeyValueStore _store;

  static const _key = 'wishlist.items';

  @override
  Future<Result<List<ProductSummary>>> load() {
    return guard(() async {
      final raw = _store.getString(_key);
      if (raw == null) return const <ProductSummary>[];
      return (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((json) => ProductSummaryModel.fromJson(json).toEntity())
          .toList();
    });
  }

  @override
  Future<Result<void>> save(List<ProductSummary> items) {
    return guard(
      () => _store.setString(
        _key,
        jsonEncode(
          items.map((p) => ProductSummaryModel.fromEntity(p).toJson()).toList(),
        ),
      ),
    );
  }

  @override
  Future<void> clearUserData() => _store.remove(_key);
}
