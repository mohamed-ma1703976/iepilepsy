import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CasesPage extends StatefulWidget {
  @override
  _CasesPageState createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  final List<Map<String, dynamic>> seizures = [
    {
      'type': 'Tonic-clonic Seizures',
      'duration': 'More than 5 minutes',
      'description': 'Known formerly as "grand mal" seizures, these involve a loss of consciousness and violent muscle contractions.',
      'effects': 'May result in fatigue and confusion post-seizure.',
    },
    {
      'type': 'Absence Seizures',
      'duration': 'Less than 2',
      'description': 'Known formerly as "petit mal" seizures, characterized by a brief, sudden lapse in consciousness.',
      'effects': 'Person appears to stare blankly and does not remember the episode.',
    },
    {
      'type': 'Atonic Seizures',
      'duration': 'Less than 2 minutes',
      'description': 'Causes a loss of muscle control, which may cause the person to collapse.',
      'effects': 'Risk of injury from falling.',
    },
    {
      'type': 'Clonic Seizures',
      'duration': '2-5 minutes',
      'description': 'Characterized by repeated jerking muscle movements.',
      'effects': 'Usually affect the neck, face, and arms.',
    },
    {
      'type': 'Tonic Seizures',
      'duration': '2-5 minutes',
      'description': 'Cause stiffening of the muscles.',
      'effects': 'Usually affects the back, arms, and legs and may result in a fall.',
    },
    {
      'type': 'Myoclonic Seizures',
      'duration': 'More than 5 minutes',
      'description': 'Involve sudden brief jerks or twitches of muscles.',
      'effects': 'Can make the person drop objects.',
    },
  ];

  IconData getIconBasedOnDuration(String duration) {
    if (duration.startsWith('Less than 2')) return Icons.linear_scale; // weak
    if (duration.startsWith('2-5')) return Icons.waves; // normal
    return Icons.electric_bolt_outlined; // strong
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCA1FF),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: seizures.length,
                    itemBuilder: (context, index) {
                      final item = seizures[index];
                      final icon = getIconBasedOnDuration(item['duration']);
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
                                leading: Icon(icon, color: Color(0xFFDCA1FF)),
                                title: Text(item['type'], style: TextStyle(color: Color(0xFFDCA1FF))),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Duration: ${item['duration']}', style: TextStyle(color: Color(0xFFDCA1FF))),
                                    SizedBox(height: 4),
                                    Text(item['description'], style: TextStyle(color: Color(0xFFDCA1FF))),
                                    SizedBox(height: 4),
                                    Text('Effects: ${item['effects']}', style: TextStyle(color: Color(0xFFDCA1FF))),
                                  ],
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
            ),
          );
        },
      ),
    );
  }
}
