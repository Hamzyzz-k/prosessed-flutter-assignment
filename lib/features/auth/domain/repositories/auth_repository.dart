import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// Signs in and stores the tokens securely.
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// The user saved on this device, or `null` when there is no session.
  Future<User?> getStoredUser();

  /// Fetches the signed-in user from the server (`GET /auth/me`).
  Future<Result<User>> getCurrentUser();

  /// Clears tokens and the stored user.
  Future<void> logout();

  /// Fires when the session expired and could not be refreshed.
  Stream<void> get onSessionExpired;
}
