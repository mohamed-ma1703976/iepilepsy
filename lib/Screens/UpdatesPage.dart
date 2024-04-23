import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      heartRate: json['heartRate'] as int? ?? 0,
      eeg: json['EEG'] as int? ?? 0,
      ir1: json['IR1'] as int? ?? 0,
      ir2: json['IR2'] as int? ?? 0,
      ir1Blinks: json['IR1Blinks'] as int? ?? 0,
      ir2Blinks: json['IR2Blinks'] as int? ?? 0,
      seizureDetected: json['SeizureDetected'] as bool? ?? false,
    );
  }
}

class SensorDataPage extends StatefulWidget {
  final String userId;

  SensorDataPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String patientId;
  SensorData? latestData;

  @override
  void initState() {
    super.initState();
    patientId = widget.userId; // Use the passed userId from the signup process
    setupDataListener();
  }

  void setupDataListener() {
    dbRef.child('path/to/your/data/node').onValue.listen((event) {
      print("Data received: ${event.snapshot.value}");
      if (event.snapshot.exists && event.snapshot.value != null) {
        Map<dynamic, dynamic> dataMap = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        List<String> sortedKeys = dataMap.keys.cast<String>().toList();
        sortedKeys.sort((a, b) => a.compareTo(b));
        String latestKey = sortedKeys.last;
        SensorData newData = SensorData.fromJson(Map<dynamic, dynamic>.from(dataMap[latestKey]));
        setState(() {
          latestData = newData; // Update state to trigger UI refresh
        });
        uploadDataToFirestore(newData); // Send data to Firestore
      }
    }, onError: (error) {
      print("Error listening to the data: $error");
    });
  }

  void uploadDataToFirestore(SensorData data) async {
    try {
      await firestore.collection('healthData').doc(patientId).set({
        'userId': patientId,
        'heartRate': data.heartRate,
        'eeg': data.eeg,
        'ir1': data.ir1,
        'ir2': data.ir2,
        'ir1Blinks': data.ir1Blinks,
        'ir2Blinks': data.ir2Blinks,
        'seizureDetected': data.seizureDetected,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error uploading data to Firestore: $e');
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
      body: latestData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            _buildSensorTile('Heart Rate', '${latestData!.heartRate} bpm', Icons.favorite),
            _buildSensorTile('EEG', '${latestData!.eeg}', Icons.waves),
            _buildSensorTile('Right Eye Blinks', '${latestData!.ir1Blinks}', Icons.visibility),
            _buildSensorTile('Left Eye Blinks', '${latestData!.ir2Blinks}', Icons.visibility),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTile(String title, String value, IconData icon) {
    return Material(
      color: Color(0xFFd1baf8),
      elevation: 2,
      borderRadius: BorderRadius.circular(15),
      child: Center(
        child: ListTile(
          title: Icon(icon, size: 40, color: Colors.white),
          subtitle: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          trailing: Text(
            value,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
