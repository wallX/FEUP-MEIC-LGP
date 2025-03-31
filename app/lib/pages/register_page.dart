import 'package:flutter/material.dart';
import '../data/user.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  UserType _selectedUserType = UserType.user;
  final TextEditingController _stationsController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {

      // TODO: Connect to backend and register user // Check if the email is already registered

      final user = User(
        name: _nameController.text,
        email: _emailController.text,
        userType: _selectedUserType,
        //token: 'example_token',
        stations: _stationsController.text.isNotEmpty
            ? _stationsController.text.split(',')
            : null,
      );

      context.read<UserProvider>().setUser(user);
      debugPrint('User Registered: ${user.name}, ${user.email}, ${user.userType}, ${user.stations}');
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildUserTypeDropdown(),
                const SizedBox(height: 16),
                _buildStationsField(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Name'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        //if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        //  return 'Please enter a valid email';
        //}
        return null;
      },
    );
  }

  Widget _buildUserTypeDropdown() {
    return DropdownButtonFormField<UserType>(
      value: _selectedUserType,
      decoration: const InputDecoration(labelText: 'User Type'),
      items: UserType.values.map((UserType type) {
        return DropdownMenuItem<UserType>(
          value: type,
          child: Text(type.toString().split('.').last),
        );
      }).toList(),
      onChanged: (UserType? newValue) {
        setState(() {
          _selectedUserType = newValue!;
        });
      },
    );
  }

  // TODO: Temporary
  Widget _buildStationsField() {
    return TextFormField(
      controller: _stationsController,
      decoration: const InputDecoration(
        labelText: 'Stations (comma-separated)',
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _register,
        child: const Text('Register'),
      ),
    );
  }


}

