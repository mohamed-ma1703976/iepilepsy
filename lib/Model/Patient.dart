import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id; // Add an ID field
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

  // Factory constructor to create a Patient instance from Firestore data
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

  // Function to fetch patient data from Firestore
  static Future<List<Patient>> fetchPatients() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('patients').get();
      return querySnapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching patients: $e");
      return [];
    }
  }
}
