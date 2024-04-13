import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../Model/Patient.dart';
import 'FamilyHomePage.dart';
import 'PatientProfilePage.dart';
import 'FamilyNotificationsPage.dart';
import 'SettingsPage.dart';

class FamilyMainHome extends StatefulWidget {
  @override
  _FamilyMainHomeState createState() => _FamilyMainHomeState();
}

class _FamilyMainHomeState extends State<FamilyMainHome> {
  int _pageIndex = 0;
  late List<Widget> _pageOptions;

  @override
  void initState() {
    super.initState();
    // Mock patient data
    Patient mockPatient = Patient(name: "John Doe", id: "123", age: 23, diagnosis:"", gender: 'Male', epilepsyType: 'High', profileImage: '' );
    _pageOptions = [
      FamilyHomePage(patient: mockPatient), // Pass the mock data here
      PatientProfilePage(),
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
            colors: [
              Color(0xFFd1baf8), // Matching gradient colors
              Color(0xFFd1baf8), // Matching gradient colors
            ],
          ),
        ),
        child: _pageOptions[_pageIndex], // The current page content
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        backgroundColor: Colors.white, // Updated background color for consistency
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Color(0xFFd1baf8)), // Matching icon color
          Icon(Icons.person, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.notifications, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.chat_outlined, size: 30, color: Color(0xFFd1baf8)),
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
