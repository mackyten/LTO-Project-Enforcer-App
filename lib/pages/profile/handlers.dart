import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/enums/collections.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/shared/models/user_model.dart';
import 'package:enforcer_auto_fine/utils/file_uploader.dart';
import 'package:enforcer_auto_fine/utils/generate_query_key_prefixes.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> handleSaveData<T extends UserModel>(T user) async {
  final db = FirebaseFirestore.instance;

  final querySnapshot = await db
      .collection(Collections.users.name)
      .where('uuid', isEqualTo: user.uuid)
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
    final currentUser = FirebaseAuth.instance.currentUser;
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
      final uploadResult = await CloudinaryService.uploadPhoto(
        user.tempProfilePicture!,
      );
      user.profilePictureUrl = uploadResult;
    }

    if (user is EnforcerModel) {
      if (badgePhoto.isNotEmpty && user.tempBadgePhoto != null) {
        await CloudinaryService.deletePhoto(badgePhoto);
        final uploadResult = await CloudinaryService.uploadPhoto(
          user.tempBadgePhoto!,
        );
        user.badgePhoto = uploadResult;
      }
    }

    // Get the document reference to perform an update.
    final docRef = docSnapshot.reference;

    // Create the update data.
    final userData = user.toJson();
    var firstNameSearchKeys = generateQueryKeyPrefixes(user.firstName);
    var lastNameSearchKeys = generateQueryKeyPrefixes(user.lastName);
    var middleNameSearchKeys = generateQueryKeyPrefixes(user.middleName ?? '');
    userData['queryKeys'] = [
      ...firstNameSearchKeys,
      ...lastNameSearchKeys,
      ...middleNameSearchKeys,
    ];

    // Update the document.
    await docRef.update(userData);
    print('Enforcer data updated successfully!');
  } else {
    print('Error: No enforcer found with uuid: ${user.uuid}');
  }
}
