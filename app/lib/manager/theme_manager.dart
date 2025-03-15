import 'package:flutter/material.dart' as material;
import 'package:app/data/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with material.ChangeNotifier {
  late SharedPreferences prefs;
  Theme _theme = Theme();
  Theme get theme => _theme;
  
  // Create only one instance of ThemeManager (Singleton)
  ThemeManager._();
  static final ThemeManager _instance = ThemeManager._();
  factory ThemeManager() => _instance;
 
  Future<void> initTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isDark') == null) prefs.setBool('isDark', false);
    _theme = Theme(isDarkMode: prefs.getBool('isDark')!);
  }
 
  void toggleTheme() {
    _theme.isDarkMode = !_theme.isDarkMode;
    prefs.setBool('isDark', _theme.isDarkMode);
    notifyListeners();
  }
}

// Global instance of ThemeManager
ThemeManager themeManager = ThemeManager();
