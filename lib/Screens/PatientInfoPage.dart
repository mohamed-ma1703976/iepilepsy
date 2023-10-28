import 'package:flutter/material.dart';
import '../Model/Patient.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class PatientInfoPage extends StatelessWidget {
  final Patient? patient;

  PatientInfoPage({this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCA1FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Patient Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: AnimationLimiter(
                  child: ClayContainer(
                    borderRadius: 25,
                    color: Color(0xFFDCA1FF),
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/default_avatar.jpg'),
                            ),
                            SizedBox(height: 20),
                            _buildInfoRow('Name', patient?.name ?? 'N/A'),
                            _buildInfoRow('Age', patient?.age.toString() ?? 'N/A'),
                            _buildInfoRow('Gender', patient?.gender ?? 'N/A'),
                            _buildInfoRow('Diagnosis', patient?.diagnosis ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 10),
        Text('$label: $value', style: TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }
}
