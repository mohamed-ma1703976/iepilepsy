import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationsPage extends StatelessWidget {
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
              itemCount: 5, // Adjust as necessary
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildNotificationTile(index, screenSize, context),
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

  Widget _buildNotificationTile(int index, Size screenSize, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: ExpansionTileCard(
        elevation: 4,
        baseColor: Color(0xFFd1baf8), // Card base color
        expandedColor: Color(0xFFd1baf8).withOpacity(0.9), // Card expanded color
        title: Text(
          "Notification ${index + 1}",
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
                  "Details for Notification ${index + 1}",
                  style: TextStyle(fontSize: 16, color: Colors.white), // Adjust text color for readability
                ),
                SizedBox(height: 10),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vehicula felis non eleifend dictum.",
                  style: TextStyle(color: Colors.white70), // Adjust text color for readability
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
