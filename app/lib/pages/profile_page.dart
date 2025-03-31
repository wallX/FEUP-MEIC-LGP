import 'package:flutter/material.dart';
import 'register_page.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/user_provider.dart';

class ProfilePage extends StatefulWidget{
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return Center(
              child: _registerButton(),
            );
          }
          return _profileInfo(user);
        },
      ),

    );
  }

  Widget _profileInfo(user){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${user?.name ?? 'N/A'}'),
          Text('Email: ${user?.email ?? 'N/A'}'),
          Text('User Type: ${user?.userType.toString() ?? 'N/A'}'),
          Text('Stations: ${user?.stations?.join(', ') ?? 'N/A'}'),
          const SizedBox(height: 16),
          _logoutButton(),  
        ],
      ),
    );
  }

  Widget _registerButton(){
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: const Text('Register'),
    );
  }

  Widget _logoutButton(){
    return ElevatedButton(
      onPressed: () {
        context.read<UserProvider>().logout();
      },
      child: const Text('Logout'),
    );
  }
}