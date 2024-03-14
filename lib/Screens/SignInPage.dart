import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../HomePage.dart'; // Update this import based on your project structure
import 'Doctor/DoctorMainHome.dart';
import 'Family_Member/FamilyMainHome.dart';
import 'SignUpPage.dart'; // Adjust the import path as necessary
import '../Repository/AuthRepository.dart'; // Ensure this path is correct for your AuthRepository
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
  final AuthRepository _authRepository = AuthRepository();

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white60),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFFcbb3e3), width: 2),
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
      _showErrorMessage("Please enter both email and password.");
      return;
    }

    try {
      UserCredential userCredential = await _authRepository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Fetch user details from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      final userType = userDoc.data()?['userType'];

      // Navigate based on user type
      if (userType == "Doctor") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DoctorMainHome()),
        );
      } else if (userType == "Family Member") {
        // Assume FamilyMainHome is correctly implemented and imported
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FamilyMainHome()), // Replace with actual navigation to FamilyMainHome
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(patientId: userCredential.user!.uid)), // Adjust as necessary
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage("Error signing in: ${e.message}");
    } catch (e) {
      _showErrorMessage("An unknown error occurred.");
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
          child: IntrinsicHeight(
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
                          child: Image.asset('assets/logo.png', height: 300, width: 300),
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
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFe8e0ed),
                            onPrimary: Color(0xFF9C27B0),
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
                                  color: Colors.white,
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
