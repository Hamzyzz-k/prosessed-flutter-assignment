import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final json = await _client.post(
      ApiEndpoints.login,
      body: {
        'username': username,
        'password': password,
        'expiresInMins': ApiEndpoints.tokenLifetimeMinutes,
      },
    );
    return parseJson<LoginResponseModel>(json, LoginResponseModel.fromJson);
  }

  @override
  Future<UserModel> getMe() async {
    final json = await _client.get(ApiEndpoints.me, requiresAuth: true);
    return parseJson<UserModel>(json, UserModel.fromJson);
  }
}
