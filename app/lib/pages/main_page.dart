import 'package:app/manager/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/nav_bar.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/profile_page.dart';

// Class main page holds all the logic of changing through the different pages
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
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
    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) => Scaffold(
        backgroundColor: themeManager.theme.backgroundColor,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
      ),
    );
  }

  @override
  void initState() {
    themeManager.addListener(themeListener);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }
}