import 'package:flutter/material.dart';

class Theme {
  late Color backgroundColor;
  late Color textColor;
  late Color primaryColor;
  late Color secondaryColor;
  
  bool isDarkMode = false;
  
  void toggleDarkMode(bool value) {
    isDarkMode = value;
    _updateColors();
  }

  Theme({bool darkMode = false}) {
    isDarkMode = darkMode;
    _updateColors();
  }
  
  void _updateColors() {
    if (isDarkMode) {
      backgroundColor = const Color.fromARGB(255, 32, 32, 32);
      textColor = const Color.fromARGB(255, 255, 250, 250);
      primaryColor = const Color.fromRGBO(241, 105, 18, 1);
      secondaryColor = const Color.fromRGBO(247, 160, 112, 1);
    } else {
      backgroundColor = const Color.fromARGB(255, 255, 255, 255);
      textColor = const Color.fromARGB(255, 0, 0, 0);
      primaryColor = const Color.fromRGBO(241, 105, 18, 1);
      secondaryColor = const Color.fromRGBO(247, 160, 112, 1);
    }
  }
}