import 'package:flutter/material.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/data/theme.dart';

class ThemeProvider extends material.ChangeNotifier{
  late SharedPreferences prefs;
  final Theme _theme = Theme();
  Theme get theme => _theme;

  bool get isDarkMode => _theme.isDarkMode;
  material.Color get backgroundColor => _theme.backgroundColor;
  material.Color get textColor => _theme.textColor;

  ThemeProvider() {
    initTheme();
  }

  void initTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isDark') == null) prefs.setBool('isDark', false);
    _theme.toggleDarkMode(prefs.getBool('isDark')!);
    notifyListeners();
  }

  void toggleTheme() {
    _theme.toggleDarkMode(!_theme.isDarkMode);
    prefs.setBool('isDark', _theme.isDarkMode);
    notifyListeners();
  }

  material.ThemeData getThemeData(){
    return material.ThemeData(
      brightness: _theme.isDarkMode ? material.Brightness.dark : material.Brightness.light,

      scaffoldBackgroundColor: _theme.backgroundColor,

      appBarTheme: material.AppBarTheme(
        backgroundColor: _theme.backgroundColor,
        titleTextStyle: material.TextStyle(color: _theme.textColor),

        iconTheme: material.IconThemeData(color: _theme.textColor),
        actionsIconTheme: material.IconThemeData(color: _theme.textColor),
        toolbarTextStyle: material.TextStyle(color: _theme.textColor),

      ),
      
      textTheme: material.TextTheme(
        bodyLarge: material.TextStyle(color: _theme.textColor),
        bodyMedium: material.TextStyle(color: _theme.textColor),
        bodySmall: material.TextStyle(color: _theme.textColor),

        titleLarge: material.TextStyle(color: _theme.textColor),
        titleMedium: material.TextStyle(color: _theme.textColor),
        titleSmall: material.TextStyle(color: _theme.textColor),

        labelLarge: material.TextStyle(color: _theme.textColor),
        labelMedium: material.TextStyle(color: _theme.textColor),
        labelSmall: material.TextStyle(color: _theme.textColor),

        displayLarge: material.TextStyle(color: _theme.textColor),
        displayMedium: material.TextStyle(color: _theme.textColor),
        displaySmall: material.TextStyle(color: _theme.textColor),

        headlineLarge: material.TextStyle(color: _theme.textColor),
        headlineMedium: material.TextStyle(color: _theme.textColor),
        headlineSmall: material.TextStyle(color: _theme.textColor),
      ),
      
      useMaterial3: true
    );
  }
}