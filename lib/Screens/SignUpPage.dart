import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../HomePage.dart';
import 'SignInPage.dart'; // Update this import based on your project structure
// Ensure you have a Patient model or adjust according to your data structure

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _epilepsyTypeController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _chronicDiseasesController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();

  String? _gender;
  String? _diagnosis;
  File? _image;
  List<String> _userTypes = ['Patient', 'Doctor', 'Family Member'];
  String? _selectedUserType;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    // Basic validation including validation for Family Member
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedUserType == null ||
        (_selectedUserType == "Patient" && (_ageController.text.isEmpty || _epilepsyTypeController.text.isEmpty || _gender == null || _diagnosis == null)) ||
        (_selectedUserType == "Doctor" && (_specializationController.text.isEmpty || _hospitalController.text.isEmpty)) ||
        (_selectedUserType == "Family Member" && _patientIdController.text.isEmpty)) {
      _showErrorMessage("Please fill in all required fields.");
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

        // Compose the user data based on the type
        Map<String, dynamic> userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'mobilePhone': _phoneController.text,
          'userType': _selectedUserType,
          'profileImage': _image != null ? _image!.path : '',
        };

        if (_selectedUserType == "Patient") {
          userData.addAll({
            'age': int.tryParse(_ageController.text) ?? 0,
            'gender': _gender!,
            'epilepsyType': _epilepsyTypeController.text,
            'chronicDiseases': _chronicDiseasesController.text, // Include chronic diseases
          });
        } else if (_selectedUserType == "Doctor") {
          userData.addAll({
            'specialization': _specializationController.text,
            'hospital': _hospitalController.text,
          });
        }
        if (_selectedUserType == "Family Member") {
          userData.addAll({
            'patientId' : _patientIdController.text,
          });
        }
        await _firestore.collection('users').doc(userId).set(userData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(), // Adjust this to your project's navigation flow
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
                    radius: 50,
                    backgroundImage: AssetImage('assets/default_avatar.jpg'),
                  )
                      : CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_image!),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _selectImage,
                  child: Text('Select Profile Picture', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                ..._buildTextFields(),
                _buildUserTypeDropdown(),
                if (_selectedUserType == "Patient") ..._buildPatientSpecificFields(),
                if (_selectedUserType == "Doctor") ..._buildDoctorSpecificFields(),
                if (_selectedUserType == "Family Member") ..._buildFamilyMemberSpecificFields(),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFe8e0ed),
                    onPrimary: Color(0xFF9C27B0),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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

  List<Widget> _buildTextFields() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _nameController,
          decoration: _inputDecoration("Enter Name"),
        ),
      ),
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
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: _inputDecoration("Confirm Password"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration("Enter Mobile Phone"),
        ),
      ),
    ];
  }

  Widget _buildUserTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        decoration: _inputDecoration("Select User Type"),
        value: _selectedUserType,
        items: _userTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedUserType = newValue;
          });
        },
        hint: Text('User Type'),
      ),
    );
  }

  List<Widget> _buildPatientSpecificFields() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration("Enter Age"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _epilepsyTypeController,
          decoration: _inputDecoration("Enter Epilepsy Type"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          decoration: _inputDecoration("Select Gender"),
          value: _gender,
          items: <String>['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _gender = newValue;
            });
          },
          hint: Text('Gender'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _chronicDiseasesController,
          decoration: _inputDecoration("Enter Chronic Diseases"),
          maxLines: null,
        ),
      ),
      // You can add more patient-specific fields here if needed
    ];
  }

  List<Widget> _buildDoctorSpecificFields() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _specializationController,
          decoration: _inputDecoration("Enter Specialization"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _hospitalController,
          decoration: _inputDecoration("Enter Hospital"),
        ),
      ),
      // Add more doctor-specific fields here if needed
    ];
  }
  List<Widget> _buildFamilyMemberSpecificFields() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _patientIdController,
          decoration: _inputDecoration("Enter Patient ID"),
        ),
      ),
      // Add more family member-specific fields here if needed
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _epilepsyTypeController.dispose();
    _specializationController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }
}
