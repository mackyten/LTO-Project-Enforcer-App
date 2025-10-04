import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../enums/user_roles.dart';
import 'firestore_base_model.dart';

class UserModel extends FirestoreBaseModel {
  final String? documentId;
  final String? uuid;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String? mobileNumber;
  String? profilePictureUrl;
  final List<UserRoles>? roles;
  final List<String>? queryKeys;
  final String? temporaryPassword;
  File? tempProfilePicture;
  File? tempBadgePhoto;

  UserModel({
    super.createdAt,
    super.lastUpdatedAt,
    super.isDeleted,
    super.deletedAt,
    this.documentId,
    this.uuid,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    this.mobileNumber,
    this.profilePictureUrl,
    this.roles,
    this.queryKeys,
    this.temporaryPassword,
    this.tempProfilePicture,
    this.tempBadgePhoto,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'documentId': documentId,
      'uuid': uuid,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'email': email,
      'mobileNumber': mobileNumber,
      'profilePictureUrl': profilePictureUrl,
      'roles': roles?.map((role) => role.toString().split('.').last).toList(),
      'queryKeys': queryKeys,
      'temporaryPassword': temporaryPassword,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
          .map(
            (role) {
              // Handle both number and string role formats
              if (role is int) {
                // Role is stored as number (index in enum)
                if (role >= 0 && role < UserRoles.values.length) {
                  return UserRoles.values[role];
                }
                return UserRoles.None;
              } else if (role is String) {
                // Role is stored as string (fallback for compatibility)
                return UserRoles.values.firstWhere(
                  (e) => e.toString().split('.').last == role,
                  orElse: () => UserRoles.None,
                );
              }
              return UserRoles.None;
            },
          )
          .toList(),
      queryKeys: json['queryKeys'] != null
          ? List<String>.from(json['queryKeys'])
          : null,
      temporaryPassword: json['temporaryPassword'],
    );
  }

  UserModel copyWith({
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
  }) {
    return UserModel(
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
    );
  }

  String getFullName() {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }
}
