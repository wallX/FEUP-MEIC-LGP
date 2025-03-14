import 'package:flutter/material.dart';
//import 'package:LGP-16/manager/theme_manager.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  //final ThemeManager themeManager;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    //required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      //backgroundColor: themeManager.theme.appColor,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle_outlined),
          label: "Profile",
        ),
      ],
      currentIndex: selectedIndex,
      //selectedItemColor: themeManager.theme.textColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      //unselectedItemColor: themeManager.theme.textColor,
      onTap: onItemTapped,
    );
  }
}