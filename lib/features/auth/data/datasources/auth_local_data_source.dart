import 'dart:convert';

import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

/// Tokens (secure storage) plus a copy of the user profile (preferences),
/// so the app can open straight into the shop without a network call.
abstract interface class AuthLocalDataSource {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  });
  Future<void> saveUser(UserModel user);

  /// The stored user, or `null` when there is no access token.
  Future<UserModel?> readSession();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._tokens, this._store);

  final TokenStorage _tokens;
  final KeyValueStore _store;

  static const _userKey = 'auth.user';

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    await _tokens.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await saveUser(user);
  }

  @override
  Future<void> saveUser(UserModel user) =>
      _store.setString(_userKey, jsonEncode(user.toJson()));

  @override
  Future<UserModel?> readSession() async {
    final token = await _tokens.readAccessToken();
    final raw = _store.getString(_userKey);
    if (token == null || raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clear() async {
    await _tokens.clear();
    await _store.remove(_userKey);
  }
}
