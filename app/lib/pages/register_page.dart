import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/token_service.dart';
import 'package:app/widgets/error_dialog.dart';
import '../data/user.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../services/token_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TokenService _tokenService = TokenService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // UserType _selectedUserType = UserType.user;
  // final TextEditingController _stationsController = TextEditingController();

  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      
      setState(() {
        _isLoading = true;
      });

      try{
        final ApiService apiService = ApiService(_tokenService);

        final response = await apiService.dio.post(
          '/api/auth/register',
          data: {
            'email': _emailController.text,
            'name': _nameController.text,
            'password': _passwordController.text,
          },
        );

        debugPrint('Register response: ${response.data}');

        if (response.statusCode == 200){
          if (!mounted) return;
        } else {
          if (!mounted) return;
          ErrorDialog.show(context: context, message: 'Register failed. Please try again.');
        }
      } catch (e) {
        debugPrint('Register failed: $e');
        if (!mounted) return;
        ErrorDialog.show(context: context, message: 'Register failed. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
        _passwordController.clear();
      }      

    if (!mounted) return;
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
                _buildPasswordField(),
                const SizedBox(height: 16),
                // _buildUserTypeDropdown(),
                // const SizedBox(height: 16),
                // _buildStationsField(),
                // const SizedBox(height: 32),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  // Widget _buildUserTypeDropdown() {
  //   return DropdownButtonFormField<UserType>(
  //     value: _selectedUserType,
  //     decoration: const InputDecoration(labelText: 'User Type'),
  //     items: UserType.values.map((UserType type) {
  //       return DropdownMenuItem<UserType>(
  //         value: type,
  //         child: Text(type.toString().split('.').last),
  //       );
  //     }).toList(),
  //     onChanged: (UserType? newValue) {
  //       setState(() {
  //         _selectedUserType = newValue!;
  //       });
  //     },
  //   );
  // }

  // TODO: Temporary
  // Widget _buildStationsField() {
  //   return TextFormField(
  //     controller: _stationsController,
  //     decoration: const InputDecoration(
  //       labelText: 'Stations (comma-separated)',
  //     ),
  //   );
  // }

  Widget _buildRegisterButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _register,
        child: const Text('Register'),
      ),
    );
  }


}

