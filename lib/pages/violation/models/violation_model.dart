class ViolationModel {
  final String violationName;
  final int repetition;
  final double price;
  final String? selectedOption; // For violations with multiple options (e.g., "attended" vs "unattended")
  final int? excessPassengers; // For overloading violations
  final Map<String, dynamic>? additionalDetails; // For any other custom details

  ViolationModel({
    required this.violationName,
    required this.repetition,
    required this.price,
    this.selectedOption,
    this.excessPassengers,
    this.additionalDetails,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    return ViolationModel(
      violationName: json['violationName'] as String,
      repetition: json['repetition'] as int,
      price: (json['price'] as num).toDouble(),
      selectedOption: json['selectedOption'] as String?,
      excessPassengers: json['excessPassengers'] as int?,
      additionalDetails: json['additionalDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'violationName': violationName,
      'repetition': repetition,
      'price': price,
      if (selectedOption != null) 'selectedOption': selectedOption,
      if (excessPassengers != null) 'excessPassengers': excessPassengers,
      if (additionalDetails != null) 'additionalDetails': additionalDetails,
    };
  }

  ViolationModel copyWith({
    String? violationName,
    int? repetition,
    double? price,
    String? selectedOption,
    int? excessPassengers,
    Map<String, dynamic>? additionalDetails,
  }) {
    return ViolationModel(
      violationName: violationName ?? this.violationName,
      repetition: repetition ?? this.repetition,
      price: price ?? this.price,
      selectedOption: selectedOption ?? this.selectedOption,
      excessPassengers: excessPassengers ?? this.excessPassengers,
      additionalDetails: additionalDetails ?? this.additionalDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViolationModel &&
        other.violationName == violationName &&
        other.repetition == repetition &&
        other.price == price &&
        other.selectedOption == selectedOption &&
        other.excessPassengers == excessPassengers &&
        other.additionalDetails == additionalDetails;
  }

  @override
  int get hashCode {
    return violationName.hashCode ^ 
           repetition.hashCode ^ 
           price.hashCode ^ 
           selectedOption.hashCode ^ 
           excessPassengers.hashCode ^ 
           additionalDetails.hashCode;
  }

  @override
  String toString() {
    return 'ViolationModel(violationName: $violationName, repetition: $repetition, price: $price, selectedOption: $selectedOption, excessPassengers: $excessPassengers, additionalDetails: $additionalDetails)';
  }
}
