import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreBaseModel {
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;
  final bool? isDeleted;
  final DateTime? deletedAt;

  FirestoreBaseModel({
    required this.createdAt,
    this.lastUpdatedAt,
    this.isDeleted,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'lastUpdatedAt': lastUpdatedAt != null ? Timestamp.fromDate(lastUpdatedAt!) : null,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory FirestoreBaseModel.fromJson(Map<String, dynamic> json) {
    return FirestoreBaseModel(
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
    );
  }

  FirestoreBaseModel copyWith({
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return FirestoreBaseModel(
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
