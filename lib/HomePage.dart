import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'Model/Patient.dart';
import 'Screens/CasesPage.dart';
import 'Screens/EmergencyNumbersPage.dart';
import 'Screens/PatientInfoPage.dart';
import 'Screens/UpdatesPage.dart';
import 'Screens/updated_home_page.dart';

class HomePage extends StatefulWidget {
  final String patientId; // Updated to use patientId

  HomePage({required this.patientId}); // Made patientId required

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  late List<Widget> _pageOptions;

  @override
  void initState() {
    super.initState();
    _pageOptions = [
      UpdatedHomePage(),
      PatientInfoPage(patientId: widget.patientId), // Updated to pass patientId
      CasesPage(),
      UpdatesPage(),
      EmergencyNumbersPage(),
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
              Color(0xFFd1baf8), // Updated to match SignInPage gradient
              Color(0xFFd1baf8), // Updated to match SignInPage gradient
            ],
          ),
        ),
        child: _pageOptions[_pageIndex], // The current page content
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        backgroundColor: Colors.white, // Updated to match SignInPage gradient
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Color(0xFFd1baf8),), // Updated icon color
          Icon(Icons.person, size: 30, color: Color(0xFFd1baf8),), // Updated icon color
          Icon(Icons.assignment, size: 30, color: Color(0xFFd1baf8),), // Updated icon color
          Icon(Icons.update, size: 30,color: Color(0xFFd1baf8),), // Updated icon color
          Icon(Icons.phone, size: 30,color: Color(0xFFd1baf8),), // Updated icon color
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
