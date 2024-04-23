import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/Patient.dart';
import '../SignInPage.dart';

class FamilyHomePage extends StatefulWidget {
  final String userId;

  FamilyHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _FamilyHomePageState createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  String? patientId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPatientId();
  }

  void fetchPatientId() async {
    try {
      DocumentSnapshot familyPatient = await FirebaseFirestore.instance
          .collection('FamilyPatient')
          .doc(widget.userId)
          .get();

      if (familyPatient.exists && familyPatient.data() != null) {
        setState(() {
          patientId = familyPatient['patientId'];
          isLoading = false;
        });
      } else {
        throw Exception("No patient data available.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.width * 0.05;

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
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Live Patient Data',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : LiveDataFeed(patientId: patientId!),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMessageDialog,
        backgroundColor: Colors.white,
        child: Icon(EvaIcons.emailOutline, color: Color(0xFFd1baf8)),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
  }

  void _showMessageDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Send a Message"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: "Title"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(hintText: "Message"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () {
                String title = titleController.text.trim();
                String body = bodyController.text.trim();
                if (title.isNotEmpty && body.isNotEmpty) {
                  _sendMessage(title, body);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _sendMessage(String title, String body) {
    if (patientId != null) {
      FirebaseFirestore.instance.collection('FamilyMessages').add({
        'patientId': patientId,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        print('Message sent successfully');
      }).catchError((error) {
        print('Failed to send message: $error');
      });
    }
  }
}

class LiveDataFeed extends StatefulWidget {
  final String patientId;

  LiveDataFeed({required this.patientId});

  @override
  _LiveDataFeedState createState() => _LiveDataFeedState();
}

class _LiveDataFeedState extends State<LiveDataFeed> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('healthData').doc(widget.patientId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(child: Text('No data available'));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var heartRate = data['heartRate'] ?? 0;
        var eeg = data['eeg'] ?? 0;
        var ir1Blinks = data['ir1Blinks'] ?? 0;
        var ir2Blinks = data['ir2Blinks'] ?? 0;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDataItem('Heart Rate', '$heartRate bpm'),
              _buildDataItem('EEG', eeg.toString()),
              _buildDataItem('IR1 Blinks', ir1Blinks.toString()),
              _buildDataItem('IR2 Blinks', ir2Blinks.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label + ':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
