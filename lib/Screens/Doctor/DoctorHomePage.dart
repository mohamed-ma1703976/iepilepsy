import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Model/Patient.dart'; // Ensure this file exists and is correctly located
import '../SignInPage.dart'; // Ensure this file exists and is correctly located

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  Future<List<Patient>> _fetchDoctorPatients() async {
    String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    List<Patient> doctorPatients = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('DoctorPatient')
        .doc(doctorId)
        .collection('patients')
        .get();

    for (var doc in querySnapshot.docs) {
      Patient patient = Patient.fromFirestore(doc);
      doctorPatients.add(patient);
    }

    return doctorPatients;
  }

  @override
  Widget build(BuildContext context) {
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
          color: Color(0xFFd1baf8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alerts', style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
                SizedBox(height: 10),
                AlertBar(),
                SizedBox(height: 20),
                Text('Your Patients', style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
                Expanded(
                  child: PatientsList(patientsFuture: _fetchDoctorPatients()),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(),
        backgroundColor: Colors.white,
        child: Icon(EvaIcons.plus, color: Color(0xFFd1baf8)),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage()));
  }

  void _showAddPatientDialog() {
    TextEditingController idController = TextEditingController();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      // Removes default icon and color
      borderSide: BorderSide(color: Color(0xFFd1baf8), width: 2),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.9,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Add Patient',
      desc: 'Enter the patient ID to add:',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Image.asset('assets/logo.png', width: 100,
                height: 100), // Logo instead of color background
          ),
          TextField(
            autofocus: true,
            controller: idController,
            decoration: InputDecoration(
              hintText: "Patient's ID",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Color(0xFFd1baf8), width: 2)),
            ),
          ),
        ],
      ),
      btnOk: ElevatedButton(
        onPressed: () async {
          final patientId = idController.text;
          String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
          FirebaseFirestore.instance.collection('users').doc(patientId)
              .get()
              .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {
              Map<String, dynamic> patientData = documentSnapshot.data() as Map<
                  String,
                  dynamic>;
              patientData['doctorId'] = doctorId;
              FirebaseFirestore.instance.collection('DoctorPatient').doc(
                  doctorId).collection('patients').doc(patientId).set(
                  patientData).then((_) {
                print("Patient added to DoctorPatient with doctorId");
                Navigator.of(context).pop();
              }).catchError((error) => print("Failed to add patient: $error"));
            } else {
              print("Patient not found");
            }
          }).catchError((error) => print("Failed to fetch patient: $error"));
        },
        style: ElevatedButton.styleFrom(
            primary: Color(0xFFd1baf8), onPrimary: Colors.white),
        child: Text('ADD'),
      ),
      btnCancelOnPress: () {},
    ).show();
  }
}

class AlertBar extends StatefulWidget {
  @override
  _AlertBarState createState() => _AlertBarState();
}

class _AlertBarState extends State<AlertBar> {
  // Implementation based on the initial request
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(EvaIcons.alertCircleOutline, color: Colors.white),
          Expanded(
            child: Text(
              'Urgent patient attention required!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(EvaIcons.arrowheadRightOutline, color: Colors.white),
            onPressed: () {
              // Navigate to details or handle the alert
            },
          ),
        ],
      ),
    );
  }
}
class PatientsList extends StatelessWidget {
  final Future<List<Patient>> patientsFuture;

  PatientsList({required this.patientsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Patient>>(
      future: patientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          var patients = snapshot.data!.take(3).toList();
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              Patient patient = patients[index];
              return ListTile(
                title: Text(patient.name, style: TextStyle(color: Colors.white)),
                subtitle: Text('${patient.diagnosis}, ${patient.age} years old', style: TextStyle(color: Colors.white70)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(EvaIcons.messageCircleOutline, color: Colors.white),
                      onPressed: () => _sendMessageDialog(context, patient.id),
                    ),
                  ],
                ),
                onTap: () {
                  print('Tapped on patient: ${patient.id}');
                  _showPatientHealthDataDialog(context, patient.id);
                },
              );
            },
          );
        } else {
          return Text("No patients found.", style: TextStyle(color: Colors.white));
        }
      },
    );
  }

  void _sendMessageDialog(BuildContext context, String patientId) {
    TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Message to Patient'),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(hintText: "Type your message here"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _saveMessageToFirestore(context, patientId, messageController.text),
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _saveMessageToFirestore(BuildContext context, String patientId, String message) {
    if (message.isNotEmpty) {
      String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
      FirebaseFirestore.instance.collection('DoctorMessages').add({
        'doctorId': doctorId,
        'patientId': patientId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message sent successfully'))
        );
      }).catchError((error) {
        print("Failed to send message: $error");
      });
    }
  }

  void _showPatientHealthDataDialog(BuildContext context, String patientId) {
    FirebaseFirestore.instance.collection('healthData').doc(patientId).get().then((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> healthData = documentSnapshot.data() as Map<String, dynamic>;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Health Data'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHealthDataItem('Heart Rate', healthData['heartRate']),
                  _buildHealthDataItem('EEG', healthData['eeg']),
                  _buildHealthDataItem('IR1', healthData['ir1']),
                  _buildHealthDataItem('IR2', healthData['ir2']),
                  _buildHealthDataItem('IR1 Blinks', healthData['ir1Blinks']),
                  _buildHealthDataItem('IR2 Blinks', healthData['ir2Blinks']),
                  _buildHealthDataItem('Seizure Detected', healthData['seizureDetected']),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          });
    }).catchError((error) {
      print("Failed to fetch health data: $error");
    });
  }

  Widget _buildHealthDataItem(String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toString()),
        ],
      ),
    );
  }
}
