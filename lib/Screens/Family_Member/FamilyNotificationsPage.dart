import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FamilyNotificationsPage extends StatelessWidget {
  // Sample data for health-focused notifications
  final List<Map<String, String>> healthNotifications = [
    {
      "title": "Daily Health Summary",
      "details": "John had a stable day with no reported seizures. Continuous monitoring showed normal activity levels. Remember tonight's medication at 8:00 PM."
    },
    {
      "title": "Medication Efficacy Update",
      "details": "Recent adjustments to John's medication appear effective. No seizures have been reported since the change. Next evaluation in two weeks."
    },
    {
      "title": "Seizure Alert",
      "details": "A mild seizure was detected this morning around 9:15 AM. It lasted for approximately 30 seconds. Please review the video logs and confirm with the care team."
    },
    {
      "title": "Appointment Reminder",
      "details": "Reminder: Tomorrow’s follow-up appointment with the neurologist is crucial to discuss John’s recent EEG results and treatment adjustments."
    },
    {
      "title": "New Symptom Alert",
      "details": "John reported experiencing unusual dizziness this afternoon. Please monitor closely and record any further occurrences to discuss during the next doctor's visit."
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
              itemCount: healthNotifications.length, // Dynamic count based on notifications list
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildHealthNotificationTile(healthNotifications[index], screenSize, context),
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

  Widget _buildHealthNotificationTile(Map<String, String> notification, Size screenSize, BuildContext context) {
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
            color: Colors.white54,
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
