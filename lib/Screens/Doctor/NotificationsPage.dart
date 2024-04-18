import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationsPage extends StatelessWidget {
  // Array containing patient-specific notification details
  final List<Map<String, String>> notifications = [
    {
      "title": "Medication Reminder",
      "details": "Reminder for John Doe to take prescribed epilepsy medication at 8:00 AM."
    },
    {
      "title": "Upcoming Neurologist Appointment",
      "details": "John Doe has a neurologist appointment on April 20th at 2:00 PM. Don't forget to prepare the recent EEG results."
    },
    {
      "title": "Seizure Detected",
      "details": "An irregular seizure activity detected for Jane Doe on April 15th. Please review the health log."
    },
    {
      "title": "Monthly Check-In",
      "details": "Reminder to schedule a monthly check-in for Jane Doe. Review medication effectiveness and discuss any recent symptoms."
    },
    {
      "title": "New Patient Registration",
      "details": "A new patient with epilepsy, Mike Ross, has been registered in the system. Initial assessment scheduled for April 18th."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFd1baf8), // Theme background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimationLimiter(
            child: ListView.builder(
              itemCount: notifications.length, // Adjust based on the size of the notifications list
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildNotificationTile(notifications[index], screenSize, context),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, String> notification, Size screenSize, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: ExpansionTileCard(
        elevation: 4,
        baseColor: Color(0xFFd1baf8), // Card base color
        expandedColor: Color(0xFFd1baf8).withOpacity(0.9), // Card expanded color
        title: Text(
          notification["title"]!,
          style: TextStyle(color: Colors.white), // Adjust text color for readability
        ),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
            color: Colors.white54, // Adjust divider color for visibility
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  notification["details"]!,
                  style: TextStyle(fontSize: 16, color: Colors.white), // Adjust text color for readability
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
