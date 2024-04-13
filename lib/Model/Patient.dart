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
      id: doc.id, // Use doc.id to get the document ID
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      diagnosis: data['diagnosis'] ?? '',
      gender: data['gender'] ?? '',
      epilepsyType: data['epilepsyType'] ?? '',
      profileImage: data['profileImage'] ?? '',
    );
  }
// Add this method to your Patient class
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'diagnosis': diagnosis,
      'gender': gender,
      'epilepsyType': epilepsyType,
      'profileImage': profileImage,
    };
  }
  static Future<Patient?> fetchPatientByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Patient.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print("Error fetching patient: $e");
      return null;
    }
  }
}
