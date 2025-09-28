import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/file_uploader.dart';
import '../../enums/collections.dart';
import 'models/appeal_model.dart';

class AppealHandlers {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Verify if violation tracking number exists
  Future<bool> verifyViolationExists(String trackingNumber) async {
    try {
      final querySnapshot = await _db
          .collection(Collections.reports.name)
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error verifying violation: $e');
      return false;
    }
  }

  /// Compress and upload files to Cloudinary
  Future<List<String>> uploadFiles(List<File> files) async {
    final List<String> uploadedUrls = [];
    
    try {
      for (File file in files) {
        File? compressedFile;
        
        // Check file size and compress if necessary
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        
        if (fileSizeInMB > 5) {
          throw Exception('File size exceeds 5MB limit');
        }
        
        // Validate and process file
        compressedFile = await _validateAndProcessFile(file);
        
        // Upload to Cloudinary
        String url = await CloudinaryService.uploadPhoto(compressedFile!);
        uploadedUrls.add(url);
      }
      
      return uploadedUrls;
    } catch (e) {
      // Clean up any uploaded files if error occurs
      await _cleanupUploadedFiles(uploadedUrls);
      throw Exception('Failed to upload files: $e');
    }
  }

  /// Check and validate file size (simplified without compression for now)
  Future<File?> _validateAndProcessFile(File file) async {
    try {
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      if (fileSizeInMB > 5) {
        throw Exception('File size exceeds 5MB limit. Please choose a smaller file.');
      }
      
      // For now, return the original file
      // TODO: Implement compression when packages are available
      return file;
    } catch (e) {
      print('Error validating file: $e');
      throw Exception('Invalid file: $e');
    }
  }

  /// Clean up uploaded files in case of failure
  Future<void> _cleanupUploadedFiles(List<String> urls) async {
    for (String url in urls) {
      try {
        await CloudinaryService.deletePhoto(url);
      } catch (e) {
        print('Error deleting file $url: $e');
      }
    }
  }

  /// Save appeal to Firestore
  Future<String?> saveAppeal(AppealModel appeal) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify violation exists
      bool violationExists = await verifyViolationExists(appeal.violationTrackingNumber);
      if (!violationExists) {
        throw Exception('Violation with tracking number ${appeal.violationTrackingNumber} not found');
      }

      // Save to Firestore
      final docRef = await _db.collection('appeals').add(appeal.toJson());
      
      print('Appeal successfully saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      // Clean up uploaded files if saving fails
      await _cleanupUploadedFiles([
        ...appeal.uploadedDocuments,
        ...appeal.supportingDocuments,
      ]);
      
      print('Error saving appeal: $e');
      throw Exception('Failed to save appeal: $e');
    }
  }
}
