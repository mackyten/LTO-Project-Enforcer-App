import 'package:enforcer_auto_fine/utils/tracking_no_generator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'violation_model.dart';

class ReportModel {
  String fullname;
  String address;
  String phoneNumber;
  String licenseNumber;
  String licensePhoto;
  String plateNumber;
  String platePhoto;
  String evidencePhoto;
  String? trackingNumber;
  String? createdById;
  List<ViolationModel> violations;
  DateTime? createdAt;
  String? draftId;

  ReportModel({
    required this.fullname,
    required this.address,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.licensePhoto,
    required this.plateNumber,
    required this.platePhoto,
    this.trackingNumber,
    this.createdById,
    required this.violations,
    required this.evidencePhoto,
    this.createdAt,
    this.draftId
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      fullname: json['fullname'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      licenseNumber: json['licenseNumber'] as String,
      licensePhoto: json['licensePhoto'] as String,
      plateNumber: json['plateNumber'] as String,
      platePhoto: json['platePhoto'] as String,
      evidencePhoto: json['evidencePhoto'] as String,
      trackingNumber: json['trackingNumber'] as String?,
      createdById: json['createdById'] as String?,
      violations: (json['violations'] as List)
          .map((v) => ViolationModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      draftId: json['draftId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime(0),
    );
  }

  Map<String, dynamic> toJson() {
    final user = FirebaseAuth.instance.currentUser;
    createdById = user?.uid;

    return {
      'fullname': fullname,
      'address': address,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'licensePhoto': licensePhoto,
      'plateNumber': plateNumber,
      'platePhoto': platePhoto,
      'violations': violations.map((v) => v.toJson()).toList(),
      'createdById': createdById,
      'evidencePhoto': evidencePhoto,
      'draftId': draftId,
      'trackingNumber': createAlphanumericTrackingNumber(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
