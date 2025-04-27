import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/theme_provider.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Use Consumer for cleaner approach to access ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Switch(
          key: const Key('change_theme_button'),
          value: themeProvider.isDarkMode,
          activeColor: themeProvider.primaryColor,
          inactiveTrackColor: themeProvider.secondaryColor,
          inactiveThumbColor: Colors.white,
          inactiveThumbImage: const AssetImage('lib/assets/sun-icon.png'), 
          activeThumbImage: const AssetImage('lib/assets/moon-icon.png'),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          onChanged: (bool value) {
            themeProvider.toggleTheme();
          },
        );
      },
    );
  }
}