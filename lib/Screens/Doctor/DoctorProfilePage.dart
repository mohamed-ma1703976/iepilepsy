import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? doctorProfile;

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        doctorProfile = docSnapshot.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd1baf8),
        title: Text("Doctor Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: doctorProfile == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: doctorProfile!['profileImage'] != null
                  ? FileImage(File(doctorProfile!['profileImage']))
                  : AssetImage('assets/default_avatar.jpg') as ImageProvider,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 20),
            Text("Dr. ${doctorProfile!['name']}", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Color(0xFFd1baf8)),
                      title: Text(doctorProfile!['email'], style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text("Email"),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Color(0xFFd1baf8)),
                      title: Text(doctorProfile!['mobilePhone'], style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text("Phone"),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.star, color: Color(0xFFd1baf8)),
                      title: Text(doctorProfile!['specialization'], style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text("Specialization"),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.local_hospital, color: Color(0xFFd1baf8)),
                      title: Text(doctorProfile!['hospital'], style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text("Hospital"),
                    ),
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
}
