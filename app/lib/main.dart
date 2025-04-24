import 'package:flutter/material.dart';
import 'package:app/pages/main_page.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/provider/submission_provider.dart';
import 'package:app/provider/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'LGP-16 App Demo',
          theme: themeProvider.getThemeData(),
          home: const MainPage(),
        );
      },
    );
  }
}

