import 'dart:convert';

import 'package:shopsphere/core/session/user_data_cleaner.dart';
import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';

/// Keeps the last successful first page of the default product list so the
/// shop still has something to show when the device is offline.
abstract interface class ProductLocalDataSource implements UserDataCleaner {
  Future<void> cacheFirstPage(ProductPageModel page);
  ProductPageModel? readFirstPage();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  const ProductLocalDataSourceImpl(this._store);

  final KeyValueStore _store;

  static const _key = 'products.firstPage';

  @override
  Future<void> cacheFirstPage(ProductPageModel page) =>
      _store.setString(_key, jsonEncode(page.toJson()));

  @override
  ProductPageModel? readFirstPage() {
    final raw = _store.getString(_key);
    if (raw == null) return null;
    try {
      return ProductPageModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // A broken cache is not worth crashing over; just ignore it.
      return null;
    }
  }

  @override
  Future<void> clearUserData() => _store.remove(_key);
}
