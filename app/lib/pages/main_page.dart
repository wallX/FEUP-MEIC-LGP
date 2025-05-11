import 'package:flutter/material.dart';
import 'package:app/widgets/nav_bar.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/profile_page.dart';
import 'package:app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/pages/login_page.dart';

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
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return _loggedOutPage();
          }
          return _loggedInPage();
        },
      ),
    );
  }

  _loggedInPage(){
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  _loggedOutPage(){
    return LoginPage();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

}