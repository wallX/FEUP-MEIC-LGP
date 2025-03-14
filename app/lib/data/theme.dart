import 'package:flutter/material.dart';

class Theme {
  late Color backgroundColor;
  late Color textColor;
  late Color buttonColor;
  
  bool isDarkMode = false;

  Theme({this.isDarkMode = false}){
    if (isDarkMode){
      backgroundColor = const Color.fromARGB(255, 0, 0, 0);
      textColor = const Color.fromARGB(255, 255, 255, 255);
      buttonColor = const Color.fromARGB(255, 255, 123, 0);
    } else {
      backgroundColor = const Color.fromARGB(255, 255, 255, 255);
      textColor = const Color.fromARGB(255, 0, 0, 0);
      buttonColor = const Color.fromARGB(255, 255, 123, 0);
    }
  }
}
