import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/session/session_events.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local, this._sessionEvents);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final SessionEvents _sessionEvents;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) {
    return guard(
      () async {
        final response = await _remote.login(
          username: username,
          password: password,
        );
        await _local.saveSession(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          user: response.user,
        );
        return response.user.toEntity();
      },
      // DummyJSON answers a wrong password with 400 "Invalid credentials".
      mapException: (e) => switch (e) {
        BadRequestException() ||
        UnauthorizedException() => InvalidCredentialsFailure(e.message),
        _ => null,
      },
    );
  }

  @override
  Future<User?> getStoredUser() async {
    try {
      return (await _local.readSession())?.toEntity();
    } on CacheException {
      // A corrupt cache is treated as "signed out" rather than a crash.
      await _local.clear();
      return null;
    }
  }

  @override
  Future<Result<User>> getCurrentUser() {
    return guard(() async {
      final user = await _remote.getMe();
      await _local.saveUser(user);
      return user.toEntity();
    });
  }

  @override
  Future<void> logout() => _local.clear();

  @override
  Stream<void> get onSessionExpired => _sessionEvents.onExpired;
}
