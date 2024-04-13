import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:typed_data'; // Required for using Uint8List

import 'SignInPage.dart';
import 'UpdatesPage.dart';
class UpdatedHomePage extends StatefulWidget {
  @override
  _UpdatedHomePageState createState() => _UpdatedHomePageState();
}

class _UpdatedHomePageState extends State<UpdatedHomePage> {
  late Future<SensorData> futureSensorData;

  Future<SensorData> fetchData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('path/to/your/data/node');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> dataMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return SensorData.fromJson(dataMap);
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureSensorData = fetchData();
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: MessageDoctorCard(),
                  ),
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
  AlertType _currentAlertType = AlertType.alert1;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _changeAlertType();
    });
  }

  void _changeAlertType() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % 4;
      _currentAlertType = AlertType.values[_currentIndex];
    });
  }

  String getAlertMessage() {
    switch (_currentAlertType) {
      case AlertType.alert1:
        return 'Seizure Detected!';
      case AlertType.alert2:
        return 'Medication Reminder.';
      case AlertType.alert3:
        return 'Appointment Reminder.';
      case AlertType.alert4:
        return 'Low Battery of the band.';
      default:
        return 'Important Message Here.';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        children: [
          Icon(EvaIcons.alertCircleOutline, color: Colors.white, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              getAlertMessage(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDoctorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMessageDialog(context);
      },
      child: ClayContainer(
        borderRadius: 25,
        depth: 20,
        spread: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(EvaIcons.emailOutline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Message Your Dr', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    TextEditingController _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Message to Your Doctor"),
          content: TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Type your message here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () async {
                try {
                  String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  DocumentSnapshot patientDoc = await FirebaseFirestore.instance.collection('DoctorPatient').doc(patientId).get();
                  if (patientDoc.exists) {
                    var data = patientDoc.data() as Map<String, dynamic>;
                    String? doctorId = data['doctorId'];
                    if (doctorId != null) {
                      await FirebaseFirestore.instance.collection('messages').add({
                        'doctorId': doctorId,
                        'patientId': patientId,
                        'message': _messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message sent successfully!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doctor ID not found.")));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Patient document does not exist.")));
                  }
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send message.")));
                }
              },
            ),
          ],
        );
      },
    );
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
