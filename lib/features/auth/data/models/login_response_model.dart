import 'package:shopsphere/features/auth/data/models/user_model.dart';

/// `POST /auth/login` returns the tokens and the user in one flat object.
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json),
    );
  }

  final String accessToken;
  final String refreshToken;
  final UserModel user;
}
