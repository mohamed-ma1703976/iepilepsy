import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/SignInPage.dart'; // Import Firebase Core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options from the google-services.json file
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: SignInPage(), // Your app's starting page
    );
  }
}
