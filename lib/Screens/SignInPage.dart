import 'package:flutter/material.dart';
import '../HomePage.dart';
import '../Repository/AuthRepository.dart';
import 'SignUpPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository(); // Create an instance of AuthRepository

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white60),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2), // Adjust the transparency as needed
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7), width: 1), // Adjust the transparency as needed
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFFcbb3e3), width: 2), // Updated to match the ribbon color
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Show an error message if email or password is empty
      _showErrorMessage("Please enter both email and password.");
      return;
    }

    try {
      // Sign in with email and password using the AuthRepository
      final user = await _authRepository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user != null) {
        // If the sign in is successful and a user is returned, navigate to the HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(patientId: user.uid)), // Pass the user ID to HomePage
        );
      } else {
        // Handle the case where the user is null (sign-in failed)
        _showErrorMessage("Sign-in failed. Please try again.");
      }
    } catch (e) {
      // Handle errors during sign-in, like wrong password or no user found
      _showErrorMessage("Error signing in: ${e.toString()}");
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
        child: ConstrainedBox(
        constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
    ),
    child: IntrinsicHeight( // Ensures the column's height matches the height of its parent
    child: Container(
      color: Color(0xFFd1baf8),
          child: AnimationConfiguration.synchronized(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 700),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset('assets/logo.png', height: 300, width: 300), // Ensure the asset path is correct
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: _inputDecoration("Enter Email"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration("Enter Password"),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _signIn, // Call the _signIn method
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFe8e0ed), // Updated to match the ribbon color
                        onPrimary: Color(0xFF9C27B0), // Change text color if needed
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Sign In"),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white, // Updated to match a lighter purple shade
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
        ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
