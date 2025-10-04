import 'package:cloud_firestore/cloud_firestore.dart';
import '../../enums/user_roles.dart';
import 'user_model.dart';

class EnforcerModel extends UserModel {
  final String? enforcerIdNumber;
  String? badgePhoto;

  // Temporary fields for uploads

  final String? tempPassword;

  EnforcerModel({
    required super.createdAt,
    super.lastUpdatedAt,
    super.isDeleted,
    super.deletedAt,
    super.documentId,
     super.uuid,
    required super.firstName,
    required super.lastName,
    super.middleName,
    required super.email,
    super.mobileNumber,
    super.profilePictureUrl,
    required super.roles,
    super.queryKeys,
    super.temporaryPassword,
    this.enforcerIdNumber,
    this.badgePhoto,
    this.tempPassword,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'enforcerIdNumber': enforcerIdNumber,
      'badgePhoto': badgePhoto,
    };
  }

  factory EnforcerModel.fromJson(Map<String, dynamic> json) {
    return EnforcerModel(
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
            (role) => UserRoles.values[role] ?? UserRoles.None,
          )
          .toList(),
      queryKeys: json['queryKeys'] != null
          ? List<String>.from(json['queryKeys'])
          : null,
      temporaryPassword: json['temporaryPassword'],
      enforcerIdNumber: json['enforcerIdNumber'],
      badgePhoto: json['badgePhoto'],
    );
  }

  @override
  EnforcerModel copyWith({
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
    String? enforcerIdNumber,
    String? badgePhoto,
    String? tempProfilePicture,
    String? tempBadgePhoto,
    String? tempPassword,
  }) {
    return EnforcerModel(
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
      enforcerIdNumber: enforcerIdNumber ?? this.enforcerIdNumber,
      badgePhoto: badgePhoto ?? this.badgePhoto,
      tempPassword: tempPassword ?? this.tempPassword,
    );
  }

  // Helper methods
  Map<String, dynamic> toUpdateJson() {
    return {
      'uuid': uuid,
      'lastUpdatedAt': DateTime.now(),
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'email': email,
      'mobileNumber': mobileNumber,
      'badgePhoto': badgePhoto,
      'enforcerIdNumber': enforcerIdNumber,
    };
  }

  @override
  String getFullName() {
    return '$firstName $lastName';
  }
}
