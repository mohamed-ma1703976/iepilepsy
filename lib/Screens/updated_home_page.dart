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
      body: SafeArea(
        child: Container(
          color: Color(0xFFd1baf8),
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
                            Image.asset(
                                'assets/logo.png',
                                height: 100,
                                width: 100,
                              ),
                            ClayContainer(
                              borderRadius: 50,
                              child: IconButton(
                                icon: Icon(EvaIcons.alertCircleOutline, color: Colors.red),
                                onPressed: () {
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
      ),
    );
  }
}

void _logout(BuildContext context) {
  // Implement your logout logic here
  // Navigate to SignInPage after logout
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
      _currentIndex = (_currentIndex + 1) % 4;
      _currentAlertType = AlertType.values[_currentIndex];
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
    _timer.cancel();
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
            child: Text(
              getAlertMessage(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
        borderRadius: 25,
        depth: 20,
        spread: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(EvaIcons.emailOutline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Message Your Dr', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
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
    {
      'title': 'Heart Rate',
      'value': '70 bpm',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
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
                fontSize: 14,
                color: Color(0xFFDCA1FF),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              reading['value'],
              style: TextStyle(color: Color(0xFFDCA1FF), fontSize: 14),
            ),
            dense: true,
          );
        }).toList(),
      ),
    );
  }
}
