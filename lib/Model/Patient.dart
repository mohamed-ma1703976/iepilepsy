import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String diagnosis;
  final String gender;
  final String epilepsyType;
  final String profileImage;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.diagnosis,
    required this.gender,
    required this.epilepsyType,
    required this.profileImage,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      diagnosis: data['diagnosis'] ?? '',
      gender: data['gender'] ?? 'Male',
      epilepsyType: data['epilepsyType'] ?? '',
      profileImage: data['profileImage'] ?? '',
    );
  }

  // Function to fetch a specific patient's data from Firestore based on user ID
  static Future<Patient?> fetchPatient(String userId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('patients').doc(userId).get();
      if (docSnapshot.exists) {
        return Patient.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print("Error fetching patient: $e");
      return null;
    }
  }
}
