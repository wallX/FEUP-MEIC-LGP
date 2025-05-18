// https://medium.com/@mvpcatalyst/exploring-token-based-authentication-and-refresh-tokens-in-flutter-6ae98eee81d8
import 'package:app/services/token_service.dart';

enum UserType {
  journalist,
  user
}

class User{
  final String name;
  final String email;
  final UserType? userType;
  TokenService tokens;
  final List<String>? stations;
  
  User({
    required this.name,
    required this.email,
    this.userType,
    required this.tokens,
    this.stations,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'userType': userType?.toString(),
      'stations': stations,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      userType: _parseUserType(json['userType']),
      tokens: TokenService(),
      stations: List<String>.from(json['stations'] ?? []),
    );
  }

  static UserType? _parseUserType(String? userTypeStr) {
    if (userTypeStr == null) return null;
    if (userTypeStr.contains('journalist')) return UserType.journalist;
    if (userTypeStr.contains('user')) return UserType.user;
    return null;
  }

  void setToken(TokenService token) {
    tokens = token;
  }
}