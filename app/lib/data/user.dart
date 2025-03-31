// https://medium.com/@mvpcatalyst/exploring-token-based-authentication-and-refresh-tokens-in-flutter-6ae98eee81d8

enum UserType {
  journalist,
  user
}

class User{
  final String name;
  final String email;
  final UserType userType;
  final List<String>? stations;
  
  User({
    required this.name,
    required this.email,
    required this.userType,
    //required this.token,
    this.stations,
  });
}