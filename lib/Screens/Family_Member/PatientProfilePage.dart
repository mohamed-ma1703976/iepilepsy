import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PatientProfilePage extends StatefulWidget {
  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? patientProfile;

  @override
  void initState() {
    super.initState();
    _fetchPatientProfile();
  }

  Future<void> _fetchPatientProfile() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // Assuming you're storing the family member's type in their profile
      DocumentSnapshot userProfile = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? userProfileData = userProfile.data() as Map<String, dynamic>?;

      // Check if the user is a 'Family Member'
      if (userProfileData != null && userProfileData['userType'] == 'Family Member') {
        // Fetch the family-patient relationship to get the patientId
        DocumentSnapshot familyPatientDoc = await _firestore.collection('FamilyPatient').doc(user.uid).get();
        Map<String, dynamic>? familyPatientData = familyPatientDoc.data() as Map<String, dynamic>?;

        if (familyPatientData != null && familyPatientData.containsKey('patientId')) {
          String patientId = familyPatientData['patientId'];
          // Fetch the patient profile using the patientId
          DocumentSnapshot patientProfileDoc = await _firestore.collection('users').doc(patientId).get();
          setState(() {
            patientProfile = patientProfileDoc.data() as Map<String, dynamic>?;
          });
        }
      } else {
        // If the user is not a 'Family Member', fetch the profile directly as before
        setState(() {
          patientProfile = userProfileData;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd1baf8),
        title: Text("Patient Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: patientProfile == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: patientProfile!['profileImage'] != null && File(patientProfile!['profileImage']).existsSync()
                  ? FileImage(File(patientProfile!['profileImage']))
                  : AssetImage('assets/default_avatar.jpg') as ImageProvider,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 20),
            Text("${patientProfile!['name'] ?? 'Name not available'}", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    _buildProfileDetail(Icons.email, patientProfile!['email'] ?? 'Email not provided', "Email"),
                    _buildProfileDetail(Icons.phone, patientProfile!['mobilePhone'] ?? 'Phone not provided', "Phone"),
                    _buildProfileDetail(Icons.cake, "${patientProfile!['age'] ?? 'Age not provided'}", "Age"),
                    _buildProfileDetail(Icons.local_hospital, patientProfile!['epilepsyType'] ?? 'Epilepsy type not provided', "Epilepsy Type"),
                    _buildProfileDetail(Icons.healing, patientProfile!['chronicDiseases'] ?? 'Chronic diseases not provided', "Chronic Diseases"),
                    // Add more fields as necessary
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text("Edit Profile"),
              onPressed: () {
                // Navigate to the profile edit page
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFd1baf8),
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Color(0xFFd1baf8),
    );
  }

  Widget _buildProfileDetail(IconData icon, String text, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Text(label, style: TextStyle(color: Colors.white70)),
    );
  }
}
