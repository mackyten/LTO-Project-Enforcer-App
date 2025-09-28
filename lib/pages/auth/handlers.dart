import 'package:enforcer_auto_fine/shared/models/response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

Future<bool> reauthenticateUser(String email, String password) async {
  // ... your reauthentication logic from the previous answer
  // This function should return true on success, and false on failure or throw an exception.
  final user = FirebaseAuth.instance.currentUser;
  try {
    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true; // Reauth successful
    }
    return false;
  } catch (e) {
    print("Reauthentication failed: $e");
    return false; // Reauth failed
  }
}

Future<ResponseModel<String>> reauthenticateAndChangePassword(
  String currentPassword,
  String newPassword,
) async {
  var response = ResponseModel<String>(null, false, null);
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    // Step 1: Reauthenticate the user
    final credential = EmailAuthProvider.credential(
      email: user.email ?? "",
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Step 2: Change the password
    await user.updatePassword(newPassword);
    response.data = "Successful";
    response.success = true;
    response.message = "Succesful";
    print("Password successfully updated.");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      response.message =
          "Error: The current password you entered is incorrect.";
    } else if (e.code == 'requires-recent-login') {
      response.message =
          "Error: This operation is sensitive and requires recent authentication. Please sign in again.";
    } else if (e.code == 'weak-password') {
      response.message =
          'Error: The new password is too weak. Please choose a stronger password.';
    } else {
      response.message =
          "An error occurred during password change: ${e.message}";
    }
  } catch (e) {
    response.message = "An unknown error occurred: $e";
  }
  return response;
}

Future<void> signOut(BuildContext context) async {
  try {
    await Future.delayed(const Duration(seconds: 2));
    await FirebaseAuth.instance.signOut();
    // User is now signed out
    print("User signed out successfully.");
    
    // Navigate to sign-in page after successful sign-out
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/', // Navigate to root which should be the auth/wrapper page
        (route) => false, // Remove all previous routes
      );
    }
  } catch (e) {
    print("Error signing out: $e");
    // Handle any errors that might occur during sign out
  }
}
