class EnforcerModel {
  String firstName;
  String lastName;
  String profilePictureUrl = '';
  String uuid;
  String email;
  String? mobileNumber;
  String? badgePhoto;

  EnforcerModel({
    required this.firstName,
    required this.lastName,
    required this.uuid,
    required this.email,
    this.mobileNumber = '',
    this.profilePictureUrl = '',
    this.badgePhoto = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'email': email,
      'uuid': uuid,
      'mobileNumber': mobileNumber,
      'badgePhoto': badgePhoto
    };
  }

  factory EnforcerModel.fromJson(Map<String, dynamic> json) {
    return EnforcerModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      email: json['email'] ?? 'no_email@no_email.com',
      uuid: json['uuid'],
      mobileNumber: json['mobileNumber'] ?? '+63',
      badgePhoto: json['badgePhoto']??''
    );
  }

  String getFullName() {
    return '$firstName $lastName';
  }
}
