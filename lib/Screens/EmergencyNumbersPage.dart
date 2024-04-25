import 'package:flutter/material.dart';
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
    var snapshot = await FirebaseFirestore.instance.collection('PatientEmergency').doc(userId).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      emergencyNumbers = List<Map<String, dynamic>>.from(data['contacts']);
      _isDataLoaded = true;
    }
    setState(() {});
  }

  Future<void> _updateEmergencyNumber(int index, String newName, String newNumber) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    emergencyNumbers[index]['name'] = newName;
    emergencyNumbers[index]['number'] = newNumber;

    await FirebaseFirestore.instance.collection('PatientEmergency').doc(userId).set({
      'contacts': emergencyNumbers
    });
    setState(() {});  // Refresh UI
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _isDataLoaded ? _buildListView() : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: emergencyNumbers.length,
      itemBuilder: (context, index) {
        final item = emergencyNumbers[index];
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          child: ListTile(
            title: Text(item['name']),
            subtitle: Text(item['number']),
            trailing: Wrap(
              spacing: 12,  // space between two icons
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call, color: Colors.red),
                  onPressed: () => _makePhoneCall(item['number']),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFcbb3e3)),
                  onPressed: () => _showEditDialog(context, index, item['name'], item['number']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index, String currentName, String currentNumber) {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController numberController = TextEditingController(text: currentNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Emergency Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context). pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateEmergencyNumber(index, nameController.text, numberController.text);
                Navigator.of(context). pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
