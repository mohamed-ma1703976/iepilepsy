import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS style switches

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _followLiveData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd1baf8),
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFd1baf8),
      body: ListView(
        children: <Widget>[
          _buildListTile(
            title: "Follow Patient's Live Data",
            subtitle: "Receive real-time updates on the patient's condition.",
            trailingWidget: CupertinoSwitch(
              value: _followLiveData,
              onChanged: (bool value) {
                setState(() {
                  _followLiveData = value;
                });
                // Implement the functionality to start or stop following patient's live data
              },
              activeColor: Color(0xFFe8e0ed),
            ),
          ),
          _buildListTile(
            title: "View Patient's Health History",
            subtitle: "Access the history of the patient's health records.",
            onTap: () {
              // Navigate to the history page
            },
          ),
          _buildListTile(
            title: "Send Alert to Patient",
            subtitle: "Quickly notify the patient or doctor of concerns.",
            onTap: () {
              // Implement the functionality to send an alert
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required String title, required String subtitle, Widget? trailingWidget, Function()? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white70)),
      trailing: trailingWidget,
      onTap: onTap,
      tileColor: Color(0xFFd1baf8).withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
