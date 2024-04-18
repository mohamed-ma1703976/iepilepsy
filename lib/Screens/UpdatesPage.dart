import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SensorData {
  final int heartRate;
  final int eeg;
  final int ir1;
  final int ir2;
  final int ir1Blinks;
  final int ir2Blinks;
  final bool seizureDetected;

  SensorData({
    required this.heartRate,
    required this.eeg,
    required this.ir1,
    required this.ir2,
    required this.ir1Blinks,
    required this.ir2Blinks,
    required this.seizureDetected,
  });

  factory SensorData.fromJson(Map<dynamic, dynamic> json) {
    return SensorData(
      heartRate: json['heartRate'] as int? ?? 70,
      eeg: json['EEG'] as int? ?? 0,
      ir1: json['IR1'] as int? ?? 3,
      ir2: json['IR2'] as int? ?? 2,
      ir1Blinks: json['IR1Blinks'] as int? ?? 3,
      ir2Blinks: json['IR2Blinks'] as int? ?? 2,
      seizureDetected: json['SeizureDetected'] as bool? ?? false,
    );
  }
}

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> { @override
final DatabaseReference dbRef = FirebaseDatabase.instance.reference();
final FirebaseFirestore firestore = FirebaseFirestore.instance;
late String patientId;
void initState() {
  super.initState();
  // Assuming the user is logged in
  patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
  // Continuously fetch and update sensor data
  fetchDataAndUpdateFirestore();
}
void fetchDataAndUpdateFirestore() async {
  // Set up a periodic timer to fetch and save data every 24 hours
  Timer.periodic(Duration(hours: 24), (timer) async {
    try {
      SensorData latestData = await fetchData();
      await firestore.collection('healthData').doc(patientId).set({
        'heartRate': latestData.heartRate,
        'eeg': latestData.eeg,
        'ir1': latestData.ir1,
        'ir2': latestData.ir2,
        'ir1Blinks': latestData.ir1Blinks,
        'ir2Blinks': latestData.ir2Blinks,
        'seizureDetected': latestData.seizureDetected,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  });
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
      backgroundColor: Color(0xFFd1baf8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Sensor Data', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<SensorData>(
        future: fetchData(),
        builder: (BuildContext context, AsyncSnapshot<SensorData> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimationLimiter(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    _buildSensorTile('Heart Rate', '${snapshot.data!.heartRate} bpm', Icons.favorite),
                    _buildSensorTile('EEG', '${snapshot.data!.eeg}', Icons.waves),
                    _buildSensorTile('Right Eye Blinks', '${snapshot.data!.ir1Blinks}', Icons.visibility),
                    _buildSensorTile('Left Eye Blinks', '${snapshot.data!.ir2Blinks}', Icons.visibility),
                  ],
                ),
              ),
            );
          } else {
            return Text('No data available');
          }
        },
      ),
    );
  }
  Widget _buildSensorTile(String title, String value, IconData icon) {
    return ClayContainer(
      borderRadius: 15,
      depth: 20,
      spread: 5,
      color: Color(0xFFd1baf8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
