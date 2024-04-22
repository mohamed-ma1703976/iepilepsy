import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../Model/Patient.dart'; // Ensure this path matches your project structure

class PatientProfilePage extends StatefulWidget {
  final String userId; // Assuming this is the Family Member's User ID

  PatientProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatient();
  }

  void _fetchPatient() async {
    DocumentSnapshot familyPatient = await FirebaseFirestore.instance
        .collection('FamilyPatient')
        .doc(widget.userId)
        .get();

    if (familyPatient.exists && familyPatient.data() != null) {
      var patientId = familyPatient['patientId'];
      Patient? patient = await Patient.fetchPatientByUserId(patientId);
      if (patient != null) {
        setState(() {
          _patient = patient;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _patient = null;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _patient = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFcbb3e3), // Apply the background color here
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _patient == null
          ? Center(child: Text("No patient data available"))
          : AnimationLimiter(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Patient Profile',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        ClayContainer(
                          borderRadius: 25,
                          color: Color(0xFFFFFFFF).withOpacity(0.5),
                          depth: 20,
                          spread: 5,
                          curveType: CurveType.convex,
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 80, // Increased size for prominence
                                  backgroundImage: _patient!.profileImage.isNotEmpty
                                      ? NetworkImage(_patient!.profileImage)
                                      : AssetImage('assets/default_avatar.jpg') as ImageProvider,
                                  backgroundColor: Colors.transparent,
                                ),
                                SizedBox(height: 20),
                                Text(_patient!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                Text("Age: ${_patient!.age}", style: TextStyle(fontSize: 18)),
                                Text("Diagnosis: ${_patient!.diagnosis}", style: TextStyle(fontSize: 18)),
                                Text("Gender: ${_patient!.gender}", style: TextStyle(fontSize: 18)),
                                Text("Epilepsy Type: ${_patient!.epilepsyType}", style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
