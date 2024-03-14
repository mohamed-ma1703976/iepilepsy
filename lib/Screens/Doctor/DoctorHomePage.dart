import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

// Assuming the Patient class is defined elsewhere in your project

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  List<Patient> patients = []; // Placeholder for patients list

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
            icon: Icon(EvaIcons.heartOutline, color: Colors.white),
            onPressed: () => _showAddPatientDialog(),
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
                Text('Live Data Feed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                LiveDataFeed(), // Placeholder for live data
                SizedBox(height: 20),
                Text('Your Patients', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Expanded(child: PatientsList(patients: patients)), // Patients list widget
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Implement logout logic here
    // For example, navigate back to the login screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showAddPatientDialog() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Patient"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Patient's Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                // Logic to add a new patient
                setState(() {
                  patients.add(Patient(id: DateTime.now().toString(), name: nameController.text, condition: 'Condition Placeholder'));
                });
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
  // Widget to show live data from patients. Placeholder for implementation.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text('Live data feed placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}

class PatientsList extends StatelessWidget {
  final List<Patient> patients;

  PatientsList({required this.patients});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(patients[index].name, style: TextStyle(color: Colors.white)),
          subtitle: Text(patients[index].condition, style: TextStyle(color: Colors.white70)),
          trailing: IconButton(
            icon: Icon(EvaIcons.alertTriangleOutline, color: Colors.white),
            onPressed: () => _sendAlert(context, patients[index]),
          ),
        );
      },
    );
  }

  void _sendAlert(BuildContext context, Patient patient) {
    // Placeholder for send alert implementation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert sent to ${patient.name}')));
  }
}

// Patient class definition
class Patient {
  final String id;
  final String name;
  final String condition;

  Patient({required this.id, required this.name, required this.condition});
}
