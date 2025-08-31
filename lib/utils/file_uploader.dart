import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:enforcer_auto_fine/enums/folders.dart';

Future<String> uploadPhoto(File photoFile, StorageFolders folderType) async {
  final cloudinary = CloudinaryPublic(
    'djw8sxxiy',
    'lto_app',
    cache: false,
  );
  try {
    CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        photoFile.path,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    print(response.secureUrl);
    return response.secureUrl;
  } on CloudinaryException catch (e) {
    print(e.message);
    print(e.request);
    throw Exception('Failed to upload photo: ${e.message}');
  }
  // var folderName = getFolderName(folderType);
  // final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  // final storageRef = FirebaseStorage.instance.ref().child('$folderName/$fileName');
  // final uploadTask = storageRef.putFile(photoFile);
  // final snapshot = await uploadTask.whenComplete(() {});
  // final downloadUrl = await snapshot.ref.getDownloadURL();
  // return downloadUrl;
}
