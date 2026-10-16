import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

/// Rules for the login form, kept out of the widgets so they can be tested.
abstract final class CredentialRules {
  static const minUsernameLength = 3;
  static const minPasswordLength = 6;

  static CredentialError? username(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return CredentialError.required;
    if (text.length < minUsernameLength) return CredentialError.tooShort;
    return null;
  }

  static CredentialError? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return CredentialError.required;
    if (text.length < minPasswordLength) return CredentialError.tooShort;
    return null;
  }
}

enum CredentialError { required, tooShort }

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String username,
    required String password,
  }) async {
    // The form already validates, but the use case must not trust its caller.
    if (CredentialRules.username(username) != null ||
        CredentialRules.password(password) != null) {
      return const Err(InvalidCredentialsFailure());
    }
    return await _repository.login(
      username: username.trim(),
      password: password,
    );
  }
}
