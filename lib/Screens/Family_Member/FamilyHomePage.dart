import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/Patient.dart'; // Ensure this path correctly leads to your Patient model

class FamilyHomePage extends StatefulWidget {
  final Patient patient;

  FamilyHomePage({required this.patient});

  @override
  _FamilyHomePageState createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make padding responsive
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
          color: Color(0xFFd1baf8), // Set the background color
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20), // Adjust space as needed
                Text(
                  'Live Patient Data',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                LiveDataFeed(patient: widget.patient),
                SizedBox(height: 20),
                // Add more widgets here as needed, they'll inherit the background color
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

  // Helper method to style message containers
  Widget _styledMessageContainer(String message) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white24, // Slightly transparent white for contrast
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, // Larger font size for visibility
            fontWeight: FontWeight.bold, // Bold text for emphasis
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Implement logout logic here, potentially involving FirebaseAuth sign-out
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
  final Patient patient;

  LiveDataFeed({required this.patient});

  @override
  _LiveDataFeedState createState() => _LiveDataFeedState();
}

class _LiveDataFeedState extends State<LiveDataFeed> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('healthData').doc(widget.patient.id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return Center(child: Text('No live data available.', style: TextStyle(color: Colors.white)));
        }
        var data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return Center(child: Text('Data is currently not available.', style: TextStyle(color: Colors.white)));
        }
        return Container(
          padding: EdgeInsets.all(16), // Provide padding for the inner text
          decoration: BoxDecoration(
            color: Colors.white24, // Slightly transparent white
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDataItem('Heart Rate', data['heartRate'] ?? 'NaN'),
              _buildDataItem('EEG', data['eeg'] ?? 'NaN'),
              // Add more data items here if needed
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataItem(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            '$value',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
