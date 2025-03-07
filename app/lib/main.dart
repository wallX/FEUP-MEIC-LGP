import 'package:flutter/material.dart';
import 'package:app/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LGP-16 App Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 93, 183, 58)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
