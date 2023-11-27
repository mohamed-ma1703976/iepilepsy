import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class UpdatesPage extends StatefulWidget {
  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final List<Map<String, dynamic>> readings = [
    {
      'title': 'Electrical Signals',
      'value': '72 Hz',
      'normalRange': '60-80 Hz',
      'instruction': 'All looks good!',
    },
    {
      'title': 'Number of Blinks',
      'value': '15 per minute',
      'normalRange': '12-20 per minute',
      'instruction': 'Normal blinking rate.',
    },
    {
      'title': 'Heart Rate',
      'value': '70 bpm',
      'normalRange': '60-100 bpm',
      'instruction': 'Heart rate is normal.',
    },
    // ... other readings can be added here
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: Color(0xFFd1baf8),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: readings.length,
                itemBuilder: (context, index) {
                  final reading = readings[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: screenWidth * 0.05),
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8), // Slightly transparent white
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reading['title'],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Color(0xFF9C27B0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.02),
                              Text('Value: ${reading['value']}', style: TextStyle(color: Color(0xFF9C27B0), fontSize: screenWidth * 0.045)),
                              SizedBox(height: screenWidth * 0.02),
                              Text('Normal Range: ${reading['normalRange']}', style: TextStyle(color: Color(0xFF9C27B0), fontSize: screenWidth * 0.04)),
                              SizedBox(height: screenWidth * 0.02),
                              Text('Instruction: ${reading['instruction']}', style: TextStyle(color: Color(0xFF9C27B0), fontSize: screenWidth * 0.04)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
