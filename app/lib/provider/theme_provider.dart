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
  material.Color get primaryColor => _theme.primaryColor;
  material.Color get secondaryColor => _theme.secondaryColor;

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
      primaryColor: _theme.primaryColor,

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
        bodyLarge: material.TextStyle(color: secondaryColor),
        bodyMedium: material.TextStyle(color: secondaryColor),
        bodySmall: material.TextStyle(color: _theme.textColor),

        titleLarge: material.TextStyle(color: secondaryColor),
        titleMedium: material.TextStyle(color: secondaryColor),
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
      
      // Login / Register Boxes
      inputDecorationTheme: material.InputDecorationTheme(
        filled: true,
        fillColor: _theme.isDarkMode ? material.Colors.grey[800] : material.Colors.white,

        floatingLabelStyle: material.TextStyle(color: primaryColor), // Floating (focused) label color

        border: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(16),
          borderSide: material.BorderSide(color: material.Colors.grey),
        ),

        enabledBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(16),
          borderSide: material.BorderSide(color: material.Colors.grey.shade400),
        ),

        focusedBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(16),
          borderSide: material.BorderSide(color: primaryColor, width: 2),
        ),

        errorBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(16),
          borderSide: material.BorderSide(color: material.Colors.red, width: 1),
        ),

        suffixIconColor: material.Colors.grey,

        contentPadding: material.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Button Theme
      elevatedButtonTheme: material.ElevatedButtonThemeData(
        style: material.ButtonStyle(
          backgroundColor: material.WidgetStateProperty.all(primaryColor),
          foregroundColor: material.WidgetStateProperty.all(material.Colors.white),
          shape: material.WidgetStateProperty.all<material.RoundedRectangleBorder>(
            material.RoundedRectangleBorder(
              borderRadius: material.BorderRadius.circular(16),
            ),
          ),
        ),
      ),

      useMaterial3: true
    );
  }
}