import 'package:flutter/foundation.dart';
import '../data/user.dart';

class UserProvider extends ChangeNotifier {

  

  User? _user;

  User? get user => _user;

  void setUser(User? newUser) {
    _user = newUser;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}