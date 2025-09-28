class ViolationModel {
  final String violationName;
  final int repetition;
  final double price;

  ViolationModel({
    required this.violationName,
    required this.repetition,
    required this.price,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    return ViolationModel(
      violationName: json['violationName'] as String,
      repetition: json['repetition'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'violationName': violationName,
      'repetition': repetition,
      'price': price,
    };
  }

  ViolationModel copyWith({
    String? violationName,
    int? repetition,
    double? price,
  }) {
    return ViolationModel(
      violationName: violationName ?? this.violationName,
      repetition: repetition ?? this.repetition,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViolationModel &&
        other.violationName == violationName &&
        other.repetition == repetition &&
        other.price == price;
  }

  @override
  int get hashCode {
    return violationName.hashCode ^ repetition.hashCode ^ price.hashCode;
  }

  @override
  String toString() {
    return 'ViolationModel(violationName: $violationName, repetition: $repetition, price: $price)';
  }
}
