import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../HomePage.dart';
import '../Model/Patient.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _epilepsyTypeController = TextEditingController();
  String? _gender;
  String? _diagnosis;
  File? _image;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  InputDecoration _inputDecoration(String hintText, double screenWidth) {
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

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _epilepsyTypeController.text.isEmpty ||
        _gender == null ||
        _diagnosis == null) {
      _showErrorMessage("Please fill in all fields.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage("Passwords do not match.");
      return;
    }

    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        final String userId = userCredential.user!.uid;

        final patient = Patient(
          id: userId,
          name: _nameController.text,
          age: int.tryParse(_ageController.text) ?? 0,
          diagnosis: _diagnosis!,
          gender: _gender!,
          epilepsyType: _epilepsyTypeController.text,
          profileImage: _image != null ? _image!.path : '',
        );

        await _firestore.collection('patients').doc(userId).set({
          'name': patient.name,
          'age': patient.age,
          'diagnosis': patient.diagnosis,
          'gender': patient.gender,
          'epilepsyType': patient.epilepsyType,
          'profileImage': patient.profileImage,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(patientId: userId),
          ),
        );
      }
    } catch (e) {
      _showErrorMessage("Error signing up. Please try again.");
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Color(0xFFd1baf8),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _selectImage,
                  child: _image == null
                      ? CircleAvatar(
                    radius: screenWidth * 0.12,
                    backgroundImage: AssetImage('assets/default_avatar.jpg'),
                  )
                      : CircleAvatar(
                    radius: screenWidth * 0.12,
                    backgroundImage: FileImage(_image!),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextButton(
                  onPressed: _selectImage,
                  child: Text('Select Profile Picture', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("Enter Name", screenWidth),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: _emailController,
                    decoration: _inputDecoration("Enter Email", screenWidth),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Enter Password", screenWidth),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Confirm Password", screenWidth),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Enter Age", screenWidth),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: _epilepsyTypeController,
                    decoration: _inputDecoration("Enter Epilepsy Type", screenWidth),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gender: ', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Radio(
                      value: 'Male',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value.toString();
                        });
                      },
                    ),
                    Text('Male', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Radio(
                      value: 'Female',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value.toString();
                        });
                      },
                    ),
                    Text('Female', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _diagnosis = value;
                      });
                    },
                    decoration: _inputDecoration("Enter Diagnosis", screenWidth),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFe8e0ed),
                    onPrimary: Color(0xFF9C27B0),
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _epilepsyTypeController.dispose();
    super.dispose();
  }
}
