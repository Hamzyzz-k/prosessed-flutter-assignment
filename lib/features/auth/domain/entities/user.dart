import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    this.phone,
    this.address,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;

  /// Only returned by `/auth/me`, not by `/auth/login`.
  final String? phone;

  /// One-line postal address, only returned by `/auth/me`.
  final String? address;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    username,
    firstName,
    lastName,
    email,
    image,
    phone,
    address,
  ];
}
