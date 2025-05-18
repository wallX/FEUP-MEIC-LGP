import 'package:app/services/token_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/user.dart';

class UserProvider extends ChangeNotifier {

  User? _user;
  final TokenService _tokenService = TokenService();

  User? get user => _user;

  Future<void> initUser() async {
    await _loadUserFromPreferences();
    
    if (_user != null) {
      await _tokenService.loadTokens();
      if (_tokenService.accessToken != null && _tokenService.refreshToken != null) {
        _user!.setToken(_tokenService);
        try {
          bool validTokens = await _user!.tokens.refreshTokens();
          if (!validTokens) {
            _user = null;
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error refreshing tokens: $e');
        }
      }
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user');
    
    if (userJson != null) {
      try {
        final Map<String, dynamic> userData = json.decode(userJson);
        _user = User.fromJson(userData);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
  }

    // Save user data to SharedPreferences
  Future<void> _saveUserToPreferences(User? user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (user != null) {
      await prefs.setString('user', json.encode(user.toJson()));
    } else {
      await prefs.remove('user');
    }
  }

  void setUser(User? newUser) {
    _user = newUser;
    _saveUserToPreferences(newUser);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}