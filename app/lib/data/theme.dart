import 'package:flutter/material.dart';

// TODO: Update with more colors such as Primary Color, when the template is done
class Theme {
  late Color backgroundColor;
  late Color textColor;
  
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  set isDarkMode(bool value) {
    _isDarkMode = value;
    _updateColors();
  }

  Theme({bool isDarkMode = false}) {
    _isDarkMode = isDarkMode;
    _updateColors();
  }
  
  void _updateColors() {
    if (_isDarkMode) {
      backgroundColor = const Color.fromARGB(255, 32, 32, 32);
      textColor = const Color.fromARGB(255, 255, 250, 250);
    } else {
      backgroundColor = const Color.fromARGB(255, 255, 255, 255);
      textColor = const Color.fromARGB(255, 0, 0, 0);
    }
  }
}