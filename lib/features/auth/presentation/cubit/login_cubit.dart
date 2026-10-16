import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_user.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.idle, this.failure, this.user});

  final LoginStatus status;
  final Failure? failure;
  final User? user;

  bool get isSubmitting => status == LoginStatus.submitting;

  @override
  List<Object?> get props => [status, failure, user];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUser) : super(const LoginState());

  final LoginUser _loginUser;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state.isSubmitting) return;
    emit(const LoginState(status: LoginStatus.submitting));
    final result = await _loginUser(username: username, password: password);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => LoginState(status: LoginStatus.success, user: value),
      Err(:final failure) => LoginState(
        status: LoginStatus.failure,
        failure: failure,
      ),
    });
  }

  /// Hides the error banner as soon as the user starts typing again.
  void clearError() {
    if (state.status == LoginStatus.failure) emit(const LoginState());
  }
}
