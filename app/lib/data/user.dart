// https://medium.com/@mvpcatalyst/exploring-token-based-authentication-and-refresh-tokens-in-flutter-6ae98eee81d8
import 'package:app/services/token_service.dart';

enum UserType {
  journalist,
  user
}

class User{
  final String name;
  final String email;
  final UserType userType;
  final TokenService tokens;
  final List<String>? stations;
  
  User({
    required this.name,
    required this.email,
    required this.userType,
    required this.tokens,
    this.stations,
  });
}