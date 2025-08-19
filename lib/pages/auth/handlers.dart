import 'package:firebase_auth/firebase_auth.dart';

Future<void> createUserWithEmailAndPassword(
  String email,
  String password,
) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Registration successful
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      // Handle weak password error
    } else if (e.code == 'email-already-in-use') {
      // Handle email already in use error
    }
  } catch (e) {
    // Handle other errors
  }
}

void signInWithEmailAndPassword(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Sign-in successful
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  } catch (e) {
    print('An error occurred while signing in: $e');
  }
}
