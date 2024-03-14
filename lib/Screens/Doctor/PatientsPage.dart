import 'package:flutter/material.dart';

// Patient model
class Patient {
  final String name;
  final int heartRate;
  final double eeg;
  final double ir1;
  final double ir2;

  Patient({
    required this.name,
    required this.heartRate,
    required this.eeg,
    required this.ir1,
    required this.ir2,
  });
}

class PatientsPage extends StatefulWidget {
  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  // Directly include a list of patients with their live data
  final List<Patient> _patients = [
    Patient(name: "John Doe", heartRate: 72, eeg: 1.2, ir1: 0.8, ir2: 0.9),
    Patient(name: "Jane Smith", heartRate: 68, eeg: 1.1, ir1: 0.7, ir2: 0.85),
    // Add more patients as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd1baf8),
        title: Text("Patients Live Data", style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return Card(
            color: Color(0xFFd1baf8).withOpacity(0.9), // Card background color
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(patient.name, style: TextStyle(color: Colors.white)),
              subtitle: Text(
                "Heart Rate: ${patient.heartRate}, EEG: ${patient.eeg}, IR1: ${patient.ir1}, IR2: ${patient.ir2}",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
      backgroundColor: Color(0xFFd1baf8), // Background color for the whole page
    );
  }
}
