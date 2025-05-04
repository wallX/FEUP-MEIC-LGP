import 'package:flutter/material.dart';
import 'package:app/pages/submission_page.dart';
import 'package:app/widgets/logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI());
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 100.0),
            Logo(logoType: 0, width: 200, height: 200),
            const SizedBox(height: 100.0),
            _recordVideoButton(),
            const SizedBox(height: 15.0),
            _buildSeparatorLine(),
            const SizedBox(height: 15.0),
            _submitVideosButton(),
          ],
        ),
      ),
    );
  }

  Widget _recordVideoButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubmissionPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(360, 50),
        textStyle: const TextStyle(
          inherit: true,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text('Record Video'),
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
        textStyle: const TextStyle(
          inherit: true,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text('Submit Videos'),
    );
  }

  Widget _buildSeparatorLine() {
    return const Divider(
      color: Colors.grey,
      height: 15,
      thickness: 0.7,
      indent: 20,
      endIndent: 20,
    );
  }
}
