import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Splash is still checking storage.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.sessionExpired = false});

  /// True when we signed the user out because the session could not be
  /// refreshed, so the login screen can explain why.
  final bool sessionExpired;

  @override
  List<Object?> get props => [sessionExpired];
}

/// App-wide session state. The router listens to it and redirects, so no
/// screen ever navigates on login or logout by hand.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._getStoredUser,
    this._getCurrentUser,
    this._logoutUser,
    WatchSessionExpired watchSessionExpired,
  ) : super(const AuthUnknown()) {
    _expirySubscription = watchSessionExpired().listen(
      (_) => unawaited(_expireSession()),
    );
  }

  final GetStoredUser _getStoredUser;
  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;
  late final StreamSubscription<void> _expirySubscription;

  /// Called once on launch: opens straight into the shop when a session is
  /// stored, then quietly validates it against the server.
  Future<void> checkSession() async {
    final user = await _getStoredUser();
    if (user == null) {
      emit(const Unauthenticated());
      return;
    }
    emit(Authenticated(user));
    await _revalidate();
  }

  void signedIn(User user) => emit(Authenticated(user));

  Future<void> logout() async {
    await _logoutUser();
    emit(const Unauthenticated());
  }

  Future<void> _revalidate() async {
    final result = await _getCurrentUser();
    if (isClosed || state is! Authenticated) return;
    switch (result) {
      case Ok(:final value):
        emit(Authenticated(value));
      case Err(failure: SessionExpiredFailure()):
        await _expireSession();
      case Err():
        // Offline or server trouble: keep the stored session and carry on.
        break;
    }
  }

  Future<void> _expireSession() async {
    if (isClosed || state is Unauthenticated) return;
    // Keep the cart: the same person is usually signing straight back in.
    await _logoutUser(clearUserData: false);
    emit(const Unauthenticated(sessionExpired: true));
  }

  @override
  Future<void> close() async {
    await _expirySubscription.cancel();
    await super.close();
  }
}
