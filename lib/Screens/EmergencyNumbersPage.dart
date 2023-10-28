import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EmergencyNumbersPage extends StatefulWidget {
  @override
  _EmergencyNumbersPageState createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends State<EmergencyNumbersPage> {
  // Sample emergency numbers. Replace this with real numbers.
  final List<Map<String, dynamic>> emergencyNumbers = [
    {'name': 'Ambulance', 'number': '112', 'icon': Icons.local_hospital},
    {'name': 'Father', 'number': '3333442', 'icon': Icons.man},
    {'name': 'Mother', 'number': '5443454', 'icon': Icons.woman},
    {'name': 'Brother', 'number': '342454', 'icon': Icons.man},
    {'name': 'My Dr', 'number': '3444555', 'icon': Icons.medical_services_outlined},
    {'name': 'Hospital', 'number': '115', 'icon': Icons.local_hospital_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCA1FF), // setting the background color
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimationLimiter(
          child: ListView.builder(
            itemCount: emergencyNumbers.length,
            itemBuilder: (context, index) {
              final item = emergencyNumbers[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Icon(item['icon'], color: Color(0xFFDCA1FF)),
                        title: Text(item['name'], style: TextStyle(color: Color(0xFFDCA1FF))),
                        subtitle: Text(item['number'], style: TextStyle(color: Color(0xFFDCA1FF))),
                        trailing: IconButton(
                          icon: Icon(Icons.call, color: Colors.amber),
                          onPressed: () {
                            // Add functionality to initiate a phone call.
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
