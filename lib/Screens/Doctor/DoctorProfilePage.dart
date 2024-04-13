import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? doctorProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    setState(() => isLoading = true);
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            doctorProfile = docSnapshot.data() as Map<String, dynamic>?;
            isLoading = false;
          });
        } else {
          // Handle no data available
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile data not available")));
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load profile: $e")));
      }
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
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: buildProfileView()),
      backgroundColor: Color(0xFFd1baf8),
    );
  }

  Widget buildProfileView() {
    if (doctorProfile == null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('No profile data available', style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    String profileImagePath = doctorProfile!['profileImage'] ?? '';
    ImageProvider profileImage = profileImagePath.isNotEmpty
        ? FileImage(File(profileImagePath))
        : AssetImage('assets/default_avatar.jpg') as ImageProvider;

    return Column(
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          radius: 60,
          backgroundImage: profileImage,
          backgroundColor: Colors.white,
        ),
        SizedBox(height: 20),
        Text("Dr. ${doctorProfile!['name']}", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        buildDetailCard(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildDetailCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            buildListTile(Icons.email, "Email", doctorProfile!['email']),
            buildDivider(),
            buildListTile(Icons.phone, "Phone", doctorProfile!['mobilePhone']),
            buildDivider(),
            buildListTile(Icons.star, "Specialization", doctorProfile!['specialization']),
            buildDivider(),
            buildListTile(Icons.local_hospital, "Hospital", doctorProfile!['hospital']),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFd1baf8)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Divider buildDivider() => Divider();
}
