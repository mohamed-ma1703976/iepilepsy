import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iepilepsy/Screens/updated_home_page.dart';
import 'Model/Patient.dart';
import 'Screens/CasesPage.dart';
import 'Screens/EmergencyNumbersPage.dart';
import 'Screens/PatientInfoPage.dart';
import 'Screens/UpdatesPage.dart';
class HomePage extends StatefulWidget {
  final Patient? patient; // Make the patient parameter optional

  HomePage({this.patient});

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
      PatientInfoPage(patient: widget.patient), // Pass the patient to PatientInfoPage
      CasesPage(),
      UpdatesPage(),
      EmergencyNumbersPage(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        backgroundColor: Colors.white,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Color(0xFFDCA1FF)),
          Icon(Icons.person, size: 30, color: Color(0xFFDCA1FF)),
          Icon(Icons.assignment, size: 30, color: Color(0xFFDCA1FF)),
          Icon(Icons.update, size: 30, color: Color(0xFFDCA1FF)),
          Icon(Icons.phone, size: 30, color: Color(0xFFDCA1FF)),
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
