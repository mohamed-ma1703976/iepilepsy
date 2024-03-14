import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signUp({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle error and print the error message
      print("Error during sign-up: $e");
      return null;
    }
  }

// Sign in with email and password
  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential; // Return the UserCredential object
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth exception e.g. wrong password, user not found etc.
      print(e);
      throw e; // Rethrow the FirebaseAuthException
    } catch (e) {
      // Handle any other errors
      print(e);
      throw Exception('An error occurred during sign in.');
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
