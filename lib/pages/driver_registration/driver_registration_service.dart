import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/utils/generate_query_key_prefixes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../enums/user_roles.dart';
import '../../shared/models/driver_model.dart';
import '../../shared/models/response_model.dart';

class DriverRegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ResponseModel<DriverModel>> registerDriver({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String plateNumber,
    required String mobileNumber,
    String? middleName,
    String? driverLicenseNumber,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) {
        return ResponseModel<DriverModel>(
          null,
          false,
          "Failed to create user account",
        );
      }
      var firstNameSearchKeys = generateQueryKeyPrefixes(firstName);
      var lastNameSearchKeys = generateQueryKeyPrefixes(lastName);
      var middleNameSearchKeys = generateQueryKeyPrefixes(middleName ?? '');

      // Create driver model
      DriverModel driverModel = DriverModel(
        createdAt: DateTime.now(),
        uuid: user.uid,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        email: email,
        mobileNumber: mobileNumber,
        roles: [UserRoles.None, UserRoles.Driver],
        driverLicenseNumber: driverLicenseNumber,
        plateNumber: plateNumber,
        queryKeys: [
          ...firstNameSearchKeys,
          ...lastNameSearchKeys,
          ...middleNameSearchKeys
        ],
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(driverModel.toJson());

      return ResponseModel<DriverModel>(
        driverModel,
        true,
        "Driver registration successful",
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      return ResponseModel<DriverModel>(null, false, errorMessage);
    } catch (e) {
      return ResponseModel<DriverModel>(
        null,
        false,
        'An unexpected error occurred: $e',
      );
    }
  }
}
