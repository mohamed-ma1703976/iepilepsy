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
    // ... other readings can be added here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCA1FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: readings.take(2).map((reading) {
                  return Container(
                    width: double.infinity, // This will make the container width to fill the available space
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                            fontSize: 20,
                            color: Color(0xFFDCA1FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Value: ${reading['value']}', style: TextStyle(color: Colors.amber, fontSize: 18)),
                        SizedBox(height: 10),
                        Text('Normal Range: ${reading['normalRange']}', style: TextStyle(color: Color(0xFFDCA1FF), fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Instruction: ${reading['instruction']}', style: TextStyle(color: Color(0xFFDCA1FF), fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
