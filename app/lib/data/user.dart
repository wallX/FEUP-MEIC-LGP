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
    this.stations,
  });
}