import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:typed_data'; // Required for using Uint8List
import 'package:rxdart/rxdart.dart';
import 'SignInPage.dart';
import 'UpdatesPage.dart';
class UpdatedHomePage extends StatefulWidget {
  @override
  _UpdatedHomePageState createState() => _UpdatedHomePageState();
}

class _UpdatedHomePageState extends State<UpdatedHomePage> {
  late Future<SensorData> futureSensorData;
  late String patientId; // Define patientId variable
  final DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Get the current user's uid as the patientId
    patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
    futureSensorData = fetchData(); // Fetch sensor data
  }

  Future<SensorData> fetchData() async {
    final snapshot = await dbRef.child('path/to/your/data/node').orderByKey().limitToLast(10).get();
    // Assuming 'path/to/your/data/node' points to a collection of records

    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> dataMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      SensorData latestValidData = SensorData(heartRate: 0, eeg: 0, ir1: 0, ir2: 0, ir1Blinks: 0, ir2Blinks: 0, seizureDetected: false);

      // Iterate in reverse to find the latest non-zero EEG value
      for (var key in dataMap.keys.toList().reversed) {
        var record = SensorData.fromJson(Map<dynamic, dynamic>.from(dataMap[key]));
        if (record.eeg != 0) {
          latestValidData = record;
          break; // Found the latest non-zero EEG value, break the loop
        }
      }

      print("Latest valid data: Heart Rate: ${latestValidData.heartRate}, EEG: ${latestValidData.eeg}, ...");
      return latestValidData;
    } else {
      print("No data found at the specified path.");
      return SensorData(heartRate: 0, eeg: 0, ir1: 0, ir2: 0, ir1Blinks: 0, ir2Blinks: 0, seizureDetected: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFd1baf8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                FutureBuilder<SensorData>(
                  future: futureSensorData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(child: widget),
                            ),
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/logo.png',
                                    height: 100,
                                    width: 100,
                                  ),
                                  ClayContainer(
                                    borderRadius: 50,
                                    depth: 20,
                                    spread: 5,
                                    color: Color(0xFFd1baf8), // Adjusted for consistency
                                    child: IconButton(
                                      icon: Icon(EvaIcons.logOutOutline, color: Colors.red),
                                      onPressed: () => _logout(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 32),
                              Text(
                                'Your Epilepsy Companion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 32),
                              AlertBar(),
                              SizedBox(height: 10),
                              CurrentReadingsBox(sensorData: snapshot.data!),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Text('No data available');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _logout(BuildContext context) {
  // Implement your logout logic here
  // Navigate to SignInPage after logout
  Navigator.of(context).pushReplacement(MaterialPageRoute(
    builder: (context) => SignInPage(),
  ));
}

enum AlertType { alert1, alert2, alert3, alert4 }
class AlertBar extends StatefulWidget {
  @override
  _AlertBarState createState() => _AlertBarState();
}

class _AlertBarState extends State<AlertBar> {
  String _latestMessage = 'No new messages available.';
  String _latestFamilyMessage = '';
  String _latestDoctorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchLatestMessages();
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _fetchLatestMessages(); // Fetch messages every 5 minutes
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLatestMessages() async {
    String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var familyMessageDoc = await FirebaseFirestore.instance
          .collection('FamilyMessages')
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      var doctorMessageDoc = await FirebaseFirestore.instance
          .collection('DoctorMessages')
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (familyMessageDoc.docs.isNotEmpty) {
        _latestFamilyMessage = familyMessageDoc.docs.first.data()['message'] ?? '';
      }

      if (doctorMessageDoc.docs.isNotEmpty) {
        _latestDoctorMessage = doctorMessageDoc.docs.first.data()['message'] ?? '';
      }

      setState(() {
        _latestMessage = _latestFamilyMessage.isNotEmpty ? _latestFamilyMessage : (_latestDoctorMessage.isNotEmpty ? _latestDoctorMessage : "No new messages.");
      });
    } catch (e) {
      print("Failed to fetch messages: $e");
    }
  }

  void _showMessagesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Latest Messages'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Family Message: $_latestFamilyMessage'),
                SizedBox(height: 16),
                Text('Doctor Message: $_latestDoctorMessage'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMessagesDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.redAccent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.warning, color: Colors.white),
            Expanded(
              child: Text(
                _latestMessage,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
  Future<String?> _fetchDoctorId() async {
    String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
    DocumentSnapshot patientDoc = await FirebaseFirestore.instance.collection('DoctorPatient').doc(patientId).get();

    if (patientDoc.exists && patientDoc.data() != null) {
      var data = patientDoc.data() as Map<String, dynamic>;  // Correct casting to Map
      String? doctorId = data['doctorId'];  // Safely accessing 'doctorId' as a String?
      return doctorId;  // Return the doctorId, or null if it doesn't exist
    }
    return null;  // Return null if the document does not exist or data is not accessible
  }
class CurrentReadingsBox extends StatelessWidget {
  final SensorData sensorData;

  CurrentReadingsBox({required this.sensorData});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> readings = [
      {
        'title': 'Heart Rate',
        'value': '${sensorData.heartRate} bpm',
      },
      {
        'title': 'EEG',
        'value': '${sensorData.eeg}',
      },
      {
        'title': 'Seizure Detected',
        'value': sensorData.seizureDetected ? 'Yes' : 'No',
      },
    ];

    return ClayContainer(
      borderRadius: 15,
      depth: 20,
      spread: 5,
      color: Color(0xFFd1baf8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: readings.map((reading) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              reading['title']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            trailing: Text(
              reading['value']!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
