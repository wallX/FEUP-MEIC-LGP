import 'package:flutter/material.dart';
import 'package:app/manager/theme_manager.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, _) {
        return Switch(
          key: const Key('change_theme_button'),
          value: themeManager.theme.isDarkMode,
          onChanged: (bool value) {
            themeManager.toggleTheme();
          }
        );
      },
    );
  }
}