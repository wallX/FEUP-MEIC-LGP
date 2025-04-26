import 'package:flutter/material.dart';
import 'package:app/pages/submission_page.dart';
import 'package:app/widgets/change_theme_button.dart';
import 'package:app/widgets/logo.dart';

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
    return Center(
      child: Column(
        children: [
    
          // Logo
          const SizedBox(height: 100.0),
          Logo(logoType: 0, width: 200, height: 200),
          const SizedBox(height: 100.0),
    
          // Submit Videos Button
          _submitVideosButton(),
    
          // Change theme switch
          const ChangeThemeButton(),
        ],
      ),
    );
  }

  Widget _submitVideosButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubmissionPage()),
        );
      },
      style: ElevatedButton.styleFrom(
            minimumSize: const Size(360, 50),
          ),
      child: const Text('Submit Videos'),
    );
  }
}
