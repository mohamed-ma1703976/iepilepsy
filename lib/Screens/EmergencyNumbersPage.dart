import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyNumbersPage extends StatefulWidget {
  @override
  _EmergencyNumbersPageState createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends State<EmergencyNumbersPage> {
  bool _isDataLoaded = false;
  List<Map<String, dynamic>> emergencyNumbers = [];

  @override
  void initState() {
    super.initState();
    _fetchEmergencyNumbers();
  }

  Future<void> _fetchEmergencyNumbers() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var snapshot = await FirebaseFirestore.instance.collection('PatientEmergency').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        emergencyNumbers = List<Map<String, dynamic>>.from(data['contacts']);
        _isDataLoaded = true;
      } else {
        _isDataLoaded = false; // No data found, consider initializing if needed
      }
    } catch (e) {
      print('Error fetching emergency numbers: $e');
      _isDataLoaded = false;
    }
    setState(() {});
  }

  Future<void> _updateEmergencyNumbers() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      await FirebaseFirestore.instance.collection('PatientEmergency').doc(userId).set({
        'contacts': emergencyNumbers
      });
    } catch (e) {
      print('Error updating emergency numbers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _isDataLoaded ? _buildListView() : _buildInitialInput(),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: emergencyNumbers.length,
        itemBuilder: (context, index) {
          final item = emergencyNumbers[index];
          TextEditingController nameController = TextEditingController(text: item['name']);
          TextEditingController numberController = TextEditingController(text: item['number']);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
                    title: TextField(
                      controller: nameController,
                      onSubmitted: (value) {
                        item['name'] = value;
                        _updateEmergencyNumbers();
                      },
                      decoration: InputDecoration(hintText: "Enter Name"),
                    ),
                    subtitle: TextField(
                      controller: numberController,
                      onSubmitted: (value) {
                        item['number'] = value;
                        _updateEmergencyNumbers();
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: "Enter Number"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () => _makePhoneCall(item['number']),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  Widget _buildInitialInput() {
    TextEditingController initialController = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: initialController,
          decoration: InputDecoration(labelText: 'Enter your doctor\'s number'),
        ),
        ElevatedButton(
          onPressed: () {
            emergencyNumbers.add({
              'name': 'My Doctor',
              'number': initialController.text,
              'icon': Icons.medical_services
            });
            _updateEmergencyNumbers();
            setState(() {
              _isDataLoaded = true;
            });
          },
          child: Text('Save'),
        )
      ],
    );
  }
}
