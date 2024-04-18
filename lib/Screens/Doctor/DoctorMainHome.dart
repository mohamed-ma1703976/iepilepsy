import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'DoctorHomePage.dart';
import 'DoctorProfilePage.dart';
import 'NotificationsPage.dart';
import 'PatientsPage.dart';
// Import other pages and utilities as before

class DoctorMainHome extends StatefulWidget {
  final String userId;

  DoctorMainHome({required this.userId});

  @override
  _DoctorMainHomeState createState() => _DoctorMainHomeState();
}

class _DoctorMainHomeState extends State<DoctorMainHome> {
  int _pageIndex = 0;
  late List<Widget> _pageOptions;

  @override
  void initState() {
    super.initState();
    _pageOptions = [
      DoctorHomePage(),
      PatientsPage(),
      NotificationsPage(),
      DoctorProfilePage(userId: widget.userId), // Pass the generated user ID here
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
          Icon(Icons.list, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.notifications, size: 30, color: Color(0xFFd1baf8)),
          Icon(Icons.person, size: 30, color: Color(0xFFd1baf8)),
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
