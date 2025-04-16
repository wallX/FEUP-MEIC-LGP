import 'package:app/services/api_service.dart';
import 'package:app/services/token_service.dart';
import 'package:flutter/material.dart';
import '../data/user.dart';
import 'package:app/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'package:app/pages/register_page.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TokenService _tokenService = TokenService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _login() async{
    if (_formKey.currentState!.validate()) {
      
      setState(() {
        _isLoading = true;
      });

      

      

      try{

        // TODO: TEMPORARY BYPASS
        if(_emailController.text == "lgp"){
          await _tokenService.saveTokens(
              accessToken: "123",
              refreshToken: "456",
            );
          final user = User(
              name: "PLACEHOLDER", //response.data['name'],
              email: _emailController.text,
              userType: UserType.journalist, //response.data['user_type'],
              tokens: _tokenService,
              stations: null, //response.data['stations'],
            );
            if (!mounted) return;
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.setUser(user);
            return;
        }


        final ApiService apiService = ApiService(_tokenService);

        final response = await apiService.dio.post(
          '/api/auth/login',
          data: {
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        debugPrint('Login response: ${response.data}');

        if (response.statusCode == 200){

          debugPrint('Login successful: ${response.data['token']}');
          await _tokenService.saveTokens(
            accessToken: response.data['token'],
            refreshToken: response.data['refresh'],
          );

          // TODO when data is added to the backend
          final user = User(
            name: "PLACEHOLDER", //response.data['name'],
            email: _emailController.text,
            userType: UserType.journalist, //response.data['user_type'],
            tokens: _tokenService,
            stations: null, //response.data['stations'],
          );

          if (!mounted) return;
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(user);
        } else {
          if (!mounted) return;
          ErrorDialog.show(context: context, message: 'Login failed. Please try again.');
        }
      } catch (e) {
        debugPrint('Login failed: $e');
        if (!mounted) return;
        ErrorDialog.show(context: context, message: 'Login failed. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
        _passwordController.clear();
      }
      

    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page Placeholder'),
      ),
      body: Padding(padding: 
      const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEmailField(),
              const SizedBox(height: 16.0),
              _buildPasswordField(),
              const SizedBox(height: 16.0),
               _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
              const SizedBox(height: 16.0),
              _registerButton()
            ],
          ),
        ),
      )

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
}