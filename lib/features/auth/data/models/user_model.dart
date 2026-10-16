import 'package:shopsphere/features/auth/domain/entities/user.dart';

/// JSON shape of a DummyJSON user (from `/auth/login` or `/auth/me`).
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    this.phone,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String? ?? '',
      phone: json['phone'] as String?,
      address: switch (json['address']) {
        final Map<String, dynamic> a => _formatAddress(a),
        final String a => a,
        _ => null,
      },
    );
  }

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    username: user.username,
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    image: user.image,
    phone: user.phone,
    address: user.address,
  );

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String? phone;
  final String? address;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'image': image,
    if (phone != null) 'phone': phone,
    if (address != null) 'address': address,
  };

  User toEntity() => User(
    id: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    image: image,
    phone: phone,
    address: address,
  );

  static String _formatAddress(Map<String, dynamic> a) {
    return [
      a['address'],
      a['city'],
      a['state'],
      a['postalCode'],
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
  }
}
