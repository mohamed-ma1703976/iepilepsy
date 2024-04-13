import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../Model/Patient.dart'; // Ensure this path matches your project structure

class PatientInfoPage extends StatefulWidget {
  final String patientId;

  PatientInfoPage({required this.patientId});

  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  late Future<Patient?> _fetchPatient;

  @override
  void initState() {
    super.initState();
    _fetchPatient = Patient.fetchPatientByUserId(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFd1baf8),
          child: FutureBuilder<Patient?>(
            future: _fetchPatient,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Center(child: Text('Error: Patient not found for ID: ${widget.patientId}'));
              }

              Patient patient = snapshot.data!;
              return buildPatientProfile(patient);
            },
          ),
        ),
      ),
    );
  }

  Widget buildPatientProfile(Patient patient) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Patient Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ClayContainer(
              borderRadius: 25,
              color: Color(0xFFFFFFFF).withOpacity(0.5),
              depth: 20,
              spread: 5,
              curveType: CurveType.convex,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(patient.profileImage),
                        backgroundColor: Color(0xFFcbb3e3),
                      ),
                      SizedBox(height: 20),
                      ...buildInfoRows(patient),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildInfoRows(Patient patient) {
    return [
      _buildInfoRow('ID', patient.id),
      _buildInfoRow('Name', patient.name),
      _buildInfoRow('Age', patient.age.toString()),
      _buildInfoRow('Gender', patient.gender),
      _buildInfoRow('Diagnosis', patient.diagnosis),
      _buildInfoRow('Epilepsy Type', patient.epilepsyType),
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF9C27B0),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
