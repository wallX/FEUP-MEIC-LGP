import 'package:flutter/material.dart';
import 'package:app/pages/main_page.dart';
import 'package:app/manager/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeManager.initTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LGP-16 App Demo',
      home: const MainPage(),
    );
  }
}

