import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppealModel {
  final String? id;
  final String violationTrackingNumber;
  final String reasonForAppeal;
  final List<String> uploadedDocuments;
  final List<String> supportingDocuments;
  final DateTime createdAt;
  String createdById;
  final String status; // pending, approved, rejected

  AppealModel({
    this.id,
    required this.violationTrackingNumber,
    required this.reasonForAppeal,
    required this.uploadedDocuments,
    required this.supportingDocuments,
    required this.createdAt,
    required this.createdById,
    this.status = 'pending',
  });

  factory AppealModel.fromJson(Map<String, dynamic> json) {
    return AppealModel(
      id: json['id'] as String?,
      violationTrackingNumber: json['violationTrackingNumber'] as String,
      reasonForAppeal: json['reasonForAppeal'] as String,
      uploadedDocuments: List<String>.from(json['uploadedDocuments'] as List),
      supportingDocuments: List<String>.from(
        json['supportingDocuments'] as List,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdById: json['createdById'] as String,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    final user = FirebaseAuth.instance.currentUser;
    createdById = user?.uid ?? "";

    return {
      'id': id,
      'violationTrackingNumber': violationTrackingNumber,
      'reasonForAppeal': reasonForAppeal,
      'uploadedDocuments': uploadedDocuments,
      'supportingDocuments': supportingDocuments,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdById': createdById,
      'status': status,
    };
  }

  AppealModel copyWith({
    String? id,
    String? violationTrackingNumber,
    String? reasonForAppeal,
    List<String>? uploadedDocuments,
    List<String>? supportingDocuments,
    DateTime? createdAt,
    String? createdById,
    String? status,
  }) {
    return AppealModel(
      id: id ?? this.id,
      violationTrackingNumber:
          violationTrackingNumber ?? this.violationTrackingNumber,
      reasonForAppeal: reasonForAppeal ?? this.reasonForAppeal,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      supportingDocuments: supportingDocuments ?? this.supportingDocuments,
      createdAt: createdAt ?? this.createdAt,
      createdById: createdById ?? this.createdById,
      status: status ?? this.status,
    );
  }
}
