import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'SignInPage.dart';

class UpdatedHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCA1FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClayContainer(
                            borderRadius: 50,
                            color: Color(0xFFDCA1FF),
                            child: Image.asset(
                              'assets/lOGO.png',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          ClayContainer(
                            color: Color(0xFFDCA1FF),
                            borderRadius: 50,
                            child: IconButton(
                              icon: Icon(EvaIcons.alertCircleOutline, color: Colors.red),
                              onPressed: () {
                                // Logout logic here
                                _logout(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Your Epilepsy Companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 32),
                      AlertBar(),
                      SizedBox(height: 10),
                      CurrentReadingsBox(),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: MessageDoctorCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void _logout(BuildContext context) {
  // Implement your logout logic here
  // For example, if you're using Firebase authentication, you would call:
  // FirebaseAuth.instance.signOut();

  // After logging out, navigate to SignInPage
  Navigator.of(context).pushReplacement(MaterialPageRoute(
    builder: (context) => SignInPage(),
  ));
}

enum AlertType { alert1, alert2, alert3, alert4 }

class AlertBar extends StatefulWidget {
  @override
  _AlertBarState createState() => _AlertBarState();
}

class _AlertBarState extends State<AlertBar> {
  AlertType _currentAlertType = AlertType.alert1;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _changeAlertType();
    });
  }

  void _changeAlertType() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % 4; // Cycle through the alerts.
      switch (_currentIndex) {
        case 0:
          _currentAlertType = AlertType.alert1;
          break;
        case 1:
          _currentAlertType = AlertType.alert2;
          break;
        case 2:
          _currentAlertType = AlertType.alert3;
          break;
        case 3:
          _currentAlertType = AlertType.alert4;
          break;
      }
    });
  }

  String getAlertMessage() {
    switch (_currentAlertType) {
      case AlertType.alert1:
        return 'Seizure Detected!';
      case AlertType.alert2:
        return 'Medication Reminder.';
      case AlertType.alert3:
        return 'Appointment Reminder.';
      case AlertType.alert4:
        return 'Low Battery of the band.';
      default:
        return 'Important Message Here.';
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        children: [
          Icon(EvaIcons.alertCircleOutline, color: Colors.white, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAlertMessage(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDoctorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMessageDialog(context);
      },
      child: ClayContainer(
        width: MediaQuery.of(context).size.width * 0.5,  // 50% of the screen width for a smaller card
        borderRadius: 25,
        depth: 20,
        spread: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),  // Reduced padding for a smaller card
          child: Row(
            children: [
              Icon(EvaIcons.emailOutline, color: Colors.amber, size: 24),  // Slightly smaller icon
              SizedBox(width: 8),  // Reduced space for a smaller card
              Text('Message Your Dr', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),  // Smaller font size
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    TextEditingController _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Message to Your Doctor"),
          content: TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Type your message here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () {
                // Logic to send the message
                // For now, it just prints the message to the console and closes the dialog
                print("Message to Dr: ${_messageController.text}");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
class CurrentReadingsBox extends StatelessWidget {
  final List<Map<String, dynamic>> readings = [
    {
      'title': 'Electrical Signals',
      'value': '72 Hz',
    },
    {
      'title': 'Number of Blinks',
      'value': '15 per minute',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10), // Simplified margin
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced vertical padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10, // Reduced blur radius
          ),
        ],
      ),
      child: Column(
        children: readings.map((reading) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              reading['title'],
              style: TextStyle(
                fontSize: 14, // Adjusted font size
                color: Color(0xFFDCA1FF),
                fontWeight: FontWeight.w500, // Lighter font weight
              ),
            ),
            trailing: Text(
              reading['value'],
              style: TextStyle(color: Color(0xFFDCA1FF), fontSize: 14),
            ),
            dense: true, // Makes it a bit more compact
          );
        }).toList(),
      ),
    );
  }
}
