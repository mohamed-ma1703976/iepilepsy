import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/Patient.dart';
import '../SignInPage.dart'; // Ensure this path correctly leads to your Patient model

class FamilyHomePage extends StatefulWidget {
  final Patient patient;

  FamilyHomePage({required this.patient});

  @override
  _FamilyHomePageState createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd1baf8),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 50, width: 50),
            IconButton(
              icon: Icon(EvaIcons.logOutOutline, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Color(0xFFd1baf8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Live Patient Data',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: LiveDataFeed(patientId: widget.patient.id), // Now passing patientId
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMessageDialog,
        backgroundColor: Colors.white,
        child: Icon(EvaIcons.emailOutline, color: Color(0xFFd1baf8)),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Implement your logout logic here
    // Navigate to SignInPage after logout
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => SignInPage(),
    ));
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
                // Here, add logic to actually send a message, perhaps through Firestore
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
class LiveDataFeed extends StatefulWidget {
  final String patientId;

  LiveDataFeed({required this.patientId});

  @override
  _LiveDataFeedState createState() => _LiveDataFeedState();
}

class _LiveDataFeedState extends State<LiveDataFeed> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('healthData').doc(widget.patientId).snapshots(),
      builder: (context, snapshot) {
        // Default values
        var heartRate = 0;
        var eeg = 0;
        var ir1Blinks = 0;
        var ir2Blinks = 0;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          heartRate = data['heartRate'] ?? 0;
          eeg = data['eeg'] ?? 0;
          ir1Blinks = data['ir1Blinks'] ?? 0;
          ir2Blinks = data['ir2Blinks'] ?? 0;
        }

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDataItem('Heart Rate', heartRate.toString()),
              _buildDataItem('EEG', eeg.toString()),
              _buildDataItem('IR1 Blinks', ir1Blinks.toString()),
              _buildDataItem('IR2 Blinks', ir2Blinks.toString()),
              // Additional data items can be added here if needed
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label + ':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
