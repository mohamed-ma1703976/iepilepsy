import 'package:flutter/material.dart';
import '../Model/Patient.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class PatientInfoPage extends StatefulWidget {
  final String patientId; // Add a field to accept patientId

  PatientInfoPage({required this.patientId});

  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {

  Future<Patient?> _fetchPatient() async {
    return Patient.fetchPatient(widget.patientId); // Fetch specific patient data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFd1baf8),
          child: FutureBuilder<Patient?>(
            future: _fetchPatient(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.data == null) {
                return Center(child: Text('Patient not found'));
              }

              Patient patient = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
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
                      child: AnimationLimiter(
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
                                    backgroundColor:  Color(0xFFcbb3e3),
                                  ),
                                  SizedBox(height: 20),
                                  _buildInfoRow('Name', patient.name),
                                  _buildInfoRow('Age', patient.age.toString()),
                                  _buildInfoRow('Gender', patient.gender),
                                  _buildInfoRow('Diagnosis', patient.diagnosis),
                                  _buildInfoRow('Epilepsy Type', patient.epilepsyType),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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
                color:Color(0xFF9C27B0),
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
