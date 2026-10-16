import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/session/user_data_cleaner.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

/// Reads the session saved on the device (no network).
class GetStoredUser {
  const GetStoredUser(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getStoredUser();
}

/// Asks the server who is signed in (`GET /auth/me`).
class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call() => _repository.getCurrentUser();
}

/// Ends the session and wipes per-user data such as the cart and wishlist.
class LogoutUser {
  const LogoutUser(this._repository, this._cleaners);

  final AuthRepository _repository;
  final List<UserDataCleaner> _cleaners;

  Future<void> call({bool clearUserData = true}) async {
    await _repository.logout();
    if (!clearUserData) return;
    for (final cleaner in _cleaners) {
      await cleaner.clearUserData();
    }
  }
}

/// Emits whenever the network layer gives up on the session.
class WatchSessionExpired {
  const WatchSessionExpired(this._repository);

  final AuthRepository _repository;

  Stream<void> call() => _repository.onSessionExpired;
}
