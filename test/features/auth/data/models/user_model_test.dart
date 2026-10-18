import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

import '../../../../helpers/helpers.dart';

void main() {
  test('LoginResponseModel reads tokens and the flat user', () {
    final response = LoginResponseModel.fromJson(fixture('login.json'));

    expect(response.accessToken, 'fake-access-token');
    expect(response.refreshToken, 'fake-refresh-token');
    expect(response.user.toEntity().fullName, 'Emily Johnson');
    expect(response.user.phone, isNull);
  });

  test('UserModel from /auth/me includes phone', () {
    final user = UserModel.fromJson(fixture('me.json')).toEntity();

    expect(user.username, 'emilys');
    expect(user.phone, isNotNull);
    expect(user.email, contains('@'));
  });

  test('UserModel turns an address object into one line', () {
    final user = UserModel.fromJson({
      ...fixture('me.json'),
      'address': {
        'address': '626 Main Street',
        'city': 'Phoenix',
        'state': 'Mississippi',
        'postalCode': '29112',
      },
    });

    expect(user.address, '626 Main Street, Phoenix, Mississippi, 29112');
  });

  test('UserModel survives a toJson round trip', () {
    final user = UserModel.fromJson(fixture('me.json'));

    expect(UserModel.fromJson(user.toJson()).toEntity(), user.toEntity());
  });
}
