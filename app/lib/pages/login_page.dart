import 'package:app/services/api_service.dart';
import 'package:app/services/token_service.dart';
import 'package:flutter/material.dart';
import '../data/user.dart';
import 'package:app/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'package:app/pages/register_page.dart';
import 'package:app/widgets/logo.dart';

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
  bool _obscurePassword = true;

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
              name: "LGP", //response.data['name'],
              email: "${_emailController.text}@mail.com",
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

          final user = User(
            name: response.data['user']['name'],
            email: response.data['user']['email'],
            userType: null, //response.data['user']['roles'],
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            const SizedBox(height: 100.0),
            Logo(logoType: 0, width: 200, height: 200),
            const SizedBox(height: 20.0),
            buildSeparatorLine(),
            const SizedBox(height: 18.0),
            buildWelcomeText(),
        
            _buildLoginForm(),
            // _buildForgotPassword(),
            const SizedBox(height: 16.0),
            _buildLoginButton(),
            const SizedBox(height: 8.0),
            _registerButton(),
            // const SizedBox(height: 2.0),
            // buildSeparatorLine(),
            // const SizedBox(height: 8.0),
            // _buildContinueWith(),
        
        
          ],
        ),
      )

    );
  }

  Widget buildSeparatorLine(){
    return const Divider(
      color: Colors.grey,
      height: 15,
      thickness: 0.7,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget buildWelcomeText(){
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 20.0), // Match the indent of the divider
        child: Text(
          'Welcome!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email Address'),
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
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        ),
      ),

      obscureText: _obscurePassword,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildEmailField(),
            const SizedBox(height: 16.0),
            _buildPasswordField(),
            const SizedBox(height: 4.0)
          ],
        ),
      )
    );
  }

  // TODO: Implement forgot password functionality
  Widget _buildForgotPassword(){
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {}, 
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(){
    return _isLoading
      ? const CircularProgressIndicator()
      : ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(360, 50),
          ),
          onPressed: _login,
          child: const Text('Login'),
        );
  }

  Widget _registerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWith(){
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Image.asset(
            'lib/assets/logo.png',
            width: 60,
            height: 60, 
          ),
        ),
      ],
    );
  }
}