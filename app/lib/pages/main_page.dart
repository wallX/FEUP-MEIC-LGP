import 'package:flutter/material.dart';
import 'package:app/widgets/nav_bar.dart';
import 'package:app/pages/home_page.dart';

// Class main page holds all the logic of changing through the different pages
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      )
    );
  }
}