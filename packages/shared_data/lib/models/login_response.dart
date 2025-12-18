import 'package:shared_data/models/courier.dart';

class LoginResponse {
  final String token;
  final Courier user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: Courier.fromJson(json['user']),
    );
  }
}
