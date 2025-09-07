import '../enums/folders.dart';

extension StorageFoldersExtension on StorageFolders {
  String get name {
    switch (this) {
      case StorageFolders.evidencePhotos:
        return 'EVIDENCE_PHOTOS';
      case StorageFolders.licensePhotos:
        return 'LICENSE_PHOTOS';
      case StorageFolders.platePhotos:
        return 'PLATE_PHOTOS';
      case StorageFolders.profilePictures:
        return 'PROFILE_PICTURES';
      case StorageFolders.badgePhotos:
        return 'BADGE_PHOTOS';
    }
  }
}
