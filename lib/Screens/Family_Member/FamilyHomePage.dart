import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import '../../Model/Patient.dart';

// Assuming the Patient class and necessary imports are defined elsewhere in your project

class FamilyHomePage extends StatefulWidget {
  final Patient patient;

  // Constructor requires a Patient object
  FamilyHomePage({required this.patient});

  @override
  _FamilyHomePageState createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd1baf8),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Assuming you have a logo.png in your assets folder
            Image.asset(
              'assets/logo.png',
              height: 50,
              width: 50,
            ),
            IconButton(
              icon: Icon(EvaIcons.logOutOutline, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(EvaIcons.messageCircleOutline, color: Colors.white),
            onPressed: () => _showMessageDialog(),
          ),
          IconButton(
            icon: Icon(EvaIcons.bellOutline, color: Colors.white),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Color(0xFFd1baf8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live Patient Data', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                LiveDataFeed(patient: widget.patient), // Live data feed for the patient
                SizedBox(height: 20),
                // Additional content or widgets specific to family members
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Implement logout logic here
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showMessageDialog() {
    TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Send a Message"),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(hintText: "Type your message here"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () {
                // Logic to send a message to the patient or doctor
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class LiveDataFeed extends StatelessWidget {
  final Patient patient;

  LiveDataFeed({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text('Live data for ${patient.name}', style: TextStyle(color: Colors.white))),
    );
  }
}
