class EnforcerModel {
  String firstName;
  String lastName;
  String profilePictureUrl = '';
  String uuid;

  EnforcerModel({
    required this.firstName,
    required this.lastName,
    required this.uuid,
    this.profilePictureUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'uuid': uuid,
    };
  }

  factory EnforcerModel.fromJson(Map<String, dynamic> json) {
    return EnforcerModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      uuid: json['uuid'],
    );
  }
}
