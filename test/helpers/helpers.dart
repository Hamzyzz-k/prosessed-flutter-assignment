import 'dart:convert';
import 'dart:io';

import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Reads a JSON fixture captured from the real DummyJSON API.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

List<dynamic> fixtureList(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as List<dynamic>;

class InMemoryKeyValueStore implements KeyValueStore {
  final values = <String, String>{};

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

class InMemoryTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

ProductSummary product({
  int id = 1,
  double price = 100,
  double discount = 10,
  int stock = 5,
  String title = 'Phone',
}) {
  return ProductSummary(
    id: id,
    title: title,
    price: price,
    discountPercentage: discount,
    rating: 4.5,
    stock: stock,
    thumbnail: 'https://example.com/$id.webp',
    category: 'smartphones',
    brand: 'Brand',
  );
}
