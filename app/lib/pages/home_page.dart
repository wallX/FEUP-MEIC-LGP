import 'package:flutter/material.dart';
import 'package:app/pages/submission_page.dart';
import 'package:app/widgets/change_theme_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: EdgeInsets.all(30.0),
            child: SvgPicture.asset(
              'lib/assets/kr-logo.svg',
              // Optional parameters for sizing
              width: 150, // Adjust as needed
              height: 150, // Adjust as needed
            ),
          ),
          // Submit Videos Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubmissionPage()),
              );
            },
            child: const Text('Submit Videos'),
          ),
          // Change theme switch
          const ChangeThemeButton(),
        ],
      ),
    );
  }
}
