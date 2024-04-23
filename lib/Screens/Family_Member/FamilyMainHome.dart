import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Model/Patient.dart';
import 'FamilyHomePage.dart';
import 'PatientProfilePage.dart';
import 'FamilyNotificationsPage.dart';
import 'SettingsPage.dart';

class FamilyMainHome extends StatefulWidget {
  final String generatedUserId; // This could be fetched from a login process or passed via arguments
  FamilyMainHome({Key? key, required this.generatedUserId}) : super(key: key);

  @override
  _FamilyMainHomeState createState() => _FamilyMainHomeState();
}

class _FamilyMainHomeState extends State<FamilyMainHome> {
  int _pageIndex = 0;
  late List<Widget> _pageOptions;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;  // To handle loading state

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      DocumentSnapshot patientProfileDoc = await _firestore.collection('users').doc(widget.generatedUserId).get();
      if (patientProfileDoc.exists) {
        setState(() {
          _initializePages(patientProfileDoc.data() as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _initializePages(null);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching patient data: $e");
      setState(() {
        _initializePages(null);
        _isLoading = false;
      });
    }
  }
  void _initializePages(Map<String, dynamic>? patientData) {
    // Convert the map to a Patient object if not null
    Patient? patient = patientData != null ? Patient.fromMap(patientData, widget.generatedUserId) : null;

    _pageOptions = [
      patient != null ? FamilyHomePage(userId: widget.generatedUserId) : PlaceholderWidget(reason: "No patient data available"),
      PatientProfilePage(userId: widget.generatedUserId),
      FamilyNotificationsPage(),
      HelpPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFd1baf8), Color(0xFFd1baf8)],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _pageOptions[_pageIndex], // Display the current page
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        backgroundColor: Colors.white,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.person, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.notifications, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.chat, size: 30, color: Color(0xFFd1baf8)),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String reason;
  PlaceholderWidget({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reason),
    );
  }
}
