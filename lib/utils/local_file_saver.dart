import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> saveImageToLocalStorage(File imageFile, String fileName) async {
  // Get the application's local documents directory.
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  final String localPath = appDocumentsDir.path;

  // Create a new file path.
  final String filePath = '$localPath/$fileName';

  // Copy the original file to the new local path.
  File newFile = await imageFile.copy(filePath);

  return newFile.path;
}