import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/enums/collections.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/utils/file_uploader.dart';

handleSaveData(UserModel user) async {
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
    final String profilePictureUrl = userDataMap['profilePictureUrl'];
    final String badgePhoto = userDataMap['badgePhoto'];

    if (profilePictureUrl.isNotEmpty &&
        user.tempProfilePicture != null &&
        user.tempProfilePicture != '') {
      final result = await CloudinaryService.deletePhoto(profilePictureUrl);
      print(result);
      user.profilePictureUrl = user.tempProfilePicture!;
    }

    if (badgePhoto.isNotEmpty &&
        user.tempProfilePicture != null &&
        user.tempProfilePicture != '') {
      final result = await CloudinaryService.deletePhoto(badgePhoto);
      print(result);
      user.badgePhoto = user.tempBadgePhoto;
    }

    // Get the document reference to perform an update.
    final docRef = docSnapshot.reference;

    // Create the update data.
    final userData = user.toUpdateJson();

    // Update the document.
    await docRef.update(userData);
    print('Enforcer data updated successfully!');
  } else {
    print('Error: No enforcer found with uuid: ${user.uuid}');
  }
}

