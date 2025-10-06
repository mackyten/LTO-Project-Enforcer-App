import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/enums/collections.dart';
import 'package:enforcer_auto_fine/shared/models/driver_model.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/shared/models/user_model.dart';
import 'package:enforcer_auto_fine/utils/file_uploader.dart';
import 'package:enforcer_auto_fine/utils/generate_query_key_prefixes.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> handleSaveData<T extends UserModel>(T user) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  final querySnapshot = await db
      .collection(Collections.users.name)
      .where('uuid', isEqualTo: currentUser?.uid)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Get the first document from the query result.
    final docSnapshot = querySnapshot.docs.first;

    // Access the data map of the document.
    final userDataMap = docSnapshot.data();

    // Now you can get the values of other fields.
    final String profilePictureUrl = userDataMap['profilePictureUrl'] ?? "";
    final String badgePhoto = userDataMap['badgePhoto'] ?? "";
    final String currentEmail = userDataMap['email'] ?? "";

    // Check if email has changed and update Firebase Auth if needed
    if (currentUser != null &&
        user.email != currentEmail &&
        user.email.isNotEmpty) {
      try {
        // Update email in Firebase Auth using our helper function
        await currentUser.updateEmail(user.email);
        // await updateUserEmail(user.email);

        print('Firebase Auth email updated successfully to: ${user.email}');
      } catch (e) {
        print('Error updating Firebase Auth email: $e');
        // Re-throw the error so the caller can handle it
        throw Exception('Failed to update authentication email: $e');
      }
    }

    if (profilePictureUrl.isNotEmpty && user.tempProfilePicture != null) {
      await CloudinaryService.deletePhoto(profilePictureUrl);
    }

    if (user.tempProfilePicture != null) {
      final uploadResult = await CloudinaryService.uploadPhoto(
        user.tempProfilePicture!,
      );
      user.profilePictureUrl = uploadResult;
    }

    if (user is EnforcerModel) {
      if (badgePhoto.isNotEmpty && user.tempBadgePhoto != null) {
        await CloudinaryService.deletePhoto(badgePhoto);
      }

      if (user.tempBadgePhoto != null) {
        final uploadResult = await CloudinaryService.uploadPhoto(
          user.tempBadgePhoto!,
        );
        user.badgePhoto = uploadResult;
      }
    }

    // Get the document reference to perform an update.
    final docRef = docSnapshot.reference;

    // Create selective update data - only include fields that should be updated
    final Map<String, dynamic> updateData = {
      'lastUpdatedAt': DateTime.now(),
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
    };

    // Only add optional fields if they have values
    if (user.middleName != null && user.middleName!.isNotEmpty) {
      updateData['middleName'] = user.middleName;
    }

    if (user.mobileNumber != null && user.mobileNumber!.isNotEmpty) {
      updateData['mobileNumber'] = user.mobileNumber;
    }

    // Update profile picture URL if it was changed
    if (user.tempProfilePicture != null) {
      updateData['profilePictureUrl'] = user.profilePictureUrl;
    }

    // Handle enforcer-specific fields
    if (user is EnforcerModel) {
      if (user.enforcerIdNumber != null && user.enforcerIdNumber!.isNotEmpty) {
        updateData['enforcerIdNumber'] = user.enforcerIdNumber;
      }

      // Update badge photo if it was changed
      if (user.tempBadgePhoto != null) {
        updateData['badgePhoto'] = user.badgePhoto;
      }
    }

    // Handle driver-specific fields
    if (user is DriverModel) {
      if (user.driverLicenseNumber != null &&
          user.driverLicenseNumber!.isNotEmpty) {
        updateData['driverLicenseNumber'] = user.driverLicenseNumber;
      }

      if (user.plateNumber != null && user.plateNumber!.isNotEmpty) {
        updateData['plateNumber'] = user.plateNumber;
      }
    }

    // Generate and update search keys
    var firstNameSearchKeys = generateQueryKeyPrefixes(user.firstName);
    var lastNameSearchKeys = generateQueryKeyPrefixes(user.lastName);
    var middleNameSearchKeys = generateQueryKeyPrefixes(user.middleName ?? '');
    updateData['queryKeys'] = [
      ...firstNameSearchKeys,
      ...lastNameSearchKeys,
      ...middleNameSearchKeys,
    ];

    // Update the document.
    await docRef.update(updateData);
    print('Enforcer data updated successfully!');
  } else {
    print('Error: No enforcer found with uuid: ${user.uuid}');
  }
}
