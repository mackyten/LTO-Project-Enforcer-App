class EnforcerIdTypeModel {
  String id;
  String type;
  String description;

  EnforcerIdTypeModel({
    required this.id,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {'Type': type, 'Description': description};
  }

  factory EnforcerIdTypeModel.fromJson(String id, Map<String, dynamic> json) {
    return EnforcerIdTypeModel(
      id: id,
      type:json['Type'] as String,
      description: json['Description'],//json['description'] as String,
    );
  }
}
