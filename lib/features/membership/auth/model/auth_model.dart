// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final String country;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'first_name': firstName,
      'second_name': lastName,
      'email': email,
      'password': password,
      'mobile': mobile,
      'country': country,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      country: map['country'] as String? ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
