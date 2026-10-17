import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads the signed-in user from `GET /auth/me`.
///
/// A 401 here goes through the auth interceptor: it refreshes the token and
/// retries, or ends the session (AuthCubit then sends the user to login).
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getCurrentUser) : super(const ProfileLoading());

  final GetCurrentUser _getCurrentUser;

  Future<void> load() async {
    emit(const ProfileLoading());
    final result = await _getCurrentUser();
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => ProfileLoaded(value),
      Err(:final failure) => ProfileFailure(failure),
    });
  }
}
