import 'package:cloud_firestore/cloud_firestore.dart';
import '../../enums/user_roles.dart';
import 'user_model.dart';

class DriverModel extends UserModel {
  final String? driverLicenseNumber;
  final String? plateNumber;

  DriverModel({
    required super.createdAt,
    super.lastUpdatedAt,
    super.isDeleted,
    super.deletedAt,
    super.documentId,
    required super.uuid,
    required super.firstName,
    required super.lastName,
    super.middleName,
    required super.email,
    super.mobileNumber,
    super.profilePictureUrl,
    required super.roles,
    super.queryKeys,
    super.temporaryPassword,
    this.driverLicenseNumber,
    this.plateNumber,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'driverLicenseNumber': driverLicenseNumber,
      'plateNumber': plateNumber,
    };
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      lastUpdatedAt: json['lastUpdatedAt'] != null 
          ? (json['lastUpdatedAt'] is Timestamp 
              ? (json['lastUpdatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['lastUpdatedAt']))
          : null,
      isDeleted: json['isDeleted'],
      deletedAt: json['deletedAt'] != null 
          ? (json['deletedAt'] is Timestamp 
              ? (json['deletedAt'] as Timestamp).toDate()
              : DateTime.parse(json['deletedAt']))
          : null,
      documentId: json['documentId'],
      uuid: json['uuid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      roles: (json['roles'] as List<dynamic>)
          .map((role) => UserRoles.values.firstWhere(
                (e) => e.toString().split('.').last == role,
                orElse: () => UserRoles.None,
              ))
          .toList(),
      queryKeys: json['queryKeys'] != null 
          ? List<String>.from(json['queryKeys']) 
          : null,
      temporaryPassword: json['temporaryPassword'],
      driverLicenseNumber: json['driverLicenseNumber'],
      plateNumber: json['plateNumber'],
    );
  }

  @override
  DriverModel copyWith({
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? documentId,
    String? uuid,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? mobileNumber,
    String? profilePictureUrl,
    List<UserRoles>? roles,
    List<String>? queryKeys,
    String? temporaryPassword,
    String? driverLicenseNumber,
    String? plateNumber,
  }) {
    return DriverModel(
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      documentId: documentId ?? this.documentId,
      uuid: uuid ?? this.uuid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      roles: roles ?? this.roles,
      queryKeys: queryKeys ?? this.queryKeys,
      temporaryPassword: temporaryPassword ?? this.temporaryPassword,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      plateNumber: plateNumber ?? this.plateNumber,
    );
  }
}
