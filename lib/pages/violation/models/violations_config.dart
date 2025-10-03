import 'violation_model.dart';

enum ViolationType { fixed, range, calculated }

class ViolationsConfig {
  static const Map<String, ViolationDefinition> definitions = {
    'driving-without-license': ViolationDefinition(
      name: 'driving-without-license',
      displayName: 'Driving without valid license',
      type: ViolationType.fixed,
      prices: {1: 3000.0, 2: 3000.0, 3: 3000.0},
    ),
    'driving-without-carrying-license': ViolationDefinition(
      name: 'driving-without-carrying-license',
      displayName: 'Driving without carrying license',
      type: ViolationType.fixed,
      prices: {1: 1000.0, 2: 1000.0, 3: 1000.0},
    ),
    'unregistered-vehicle': ViolationDefinition(
      name: 'unregistered-vehicle',
      displayName: 'Unregistered vehicle',
      type: ViolationType.fixed,
      prices: {1: 10000.0, 2: 10000.0, 3: 10000.0},
    ),
    'reckless-driving': ViolationDefinition(
      name: 'reckless-driving',
      displayName: 'Reckless driving',
      type: ViolationType.fixed,
      prices: {1: 2000.0, 2: 3000.0, 3: 10000.0},
    ),
    'disregarding-traffic-signs': ViolationDefinition(
      name: 'disregarding-traffic-signs',
      displayName: 'Disregarding traffic signs/ red light',
      type: ViolationType.fixed,
      prices: {1: 1000.0, 2: 1000.0, 3: 1000.0},
    ),
    'illegal-parking': ViolationDefinition(
      name: 'illegal-parking',
      displayName: 'Illegal parking',
      type: ViolationType.range,
      prices: {1: 1000.0, 2: 1000.0, 3: 1000.0},
      options: ['Attended (₱1,000)', 'Unattended (₱2,000)'],
      optionPrices: [1000.0, 2000.0],
    ),
    'number-coding-violation': ViolationDefinition(
      name: 'number-coding-violation',
      displayName: 'Number coding violation (MMDA)',
      type: ViolationType.fixed,
      prices: {1: 300.0, 2: 300.0, 3: 300.0},
    ),
    'no-helmet': ViolationDefinition(
      name: 'no-helmet',
      displayName: 'No Helmet (motorcycle)',
      type: ViolationType.fixed,
      prices: {1: 1500.0, 2: 3000.0, 3: 5000.0, 4: 10000.0},
    ),
    'no-seatbelt': ViolationDefinition(
      name: 'no-seatbelt',
      displayName: 'No seatbelt',
      type: ViolationType.fixed,
      prices: {1: 1000.0, 2: 2000.0, 3: 5000.0},
    ),
    'driving-under-influence': ViolationDefinition(
      name: 'driving-under-influence',
      displayName: 'Driving under influence',
      type: ViolationType.range,
      minPrice: 50000.0,
      maxPrice: 500000.0,
    ),
    'overloading': ViolationDefinition(
      name: 'overloading',
      displayName: 'Overloading (PUVs)',
      type: ViolationType.calculated,
      prices: {1: 5000.0, 2: 5000.0, 3: 5000.0},
      excessPassengerFee: 2000.0,
    ),
    'operating-without-franchise': ViolationDefinition(
      name: 'operating-without-franchise',
      displayName: 'Operating without franchise (PUVs)',
      type: ViolationType.range,
      minPrice: 5000.0,
      maxPrice: 10000.0,
    ),
    'using-phone-while-driving': ViolationDefinition(
      name: 'using-phone-while-driving',
      displayName: 'Using phone while driving',
      type: ViolationType.fixed,
      prices: {1: 1000.0, 2: 2000.0, 3: 3000.0, 4: 5000.0},
    ),
    'obstruction': ViolationDefinition(
      name: 'obstruction',
      displayName: 'Obstruction (crossing/driveway)',
      type: ViolationType.fixed,
      prices: {1: 1000.0, 2: 1000.0, 3: 1000.0},
    ),
    'smoke-belching': ViolationDefinition(
      name: 'smoke-belching',
      displayName: 'Smoke belching / emission',
      type: ViolationType.fixed,
      prices: {1: 2000.0, 2: 4000.0, 3: 6000.0},
    ),
    'other': ViolationDefinition(
      name: 'other',
      displayName: 'Other',
      type: ViolationType.range,
      minPrice: 500.0,
      maxPrice: 100000.0,
    ),
  };

  /// Convert selected violations from Map<String, bool> to List<ViolationModel>
  static List<ViolationModel> fromSelectedViolations(Map<String, dynamic> selectedViolations) {
    return selectedViolations.entries
        .where((entry) => entry.value is bool && entry.value) // Only selected violations
        .map((entry) {
          final violationDef = definitions[entry.key];
          if (violationDef != null) {
            return ViolationModel(
              violationName: violationDef.displayName,
              repetition: 1, // Default repetition
              price: violationDef.getDefaultPrice(),
              selectedOption: null, // No custom option for simple selections
              excessPassengers: null, // No excess passengers for simple selections
              additionalDetails: null, // No additional details for simple selections
            );
          } else {
            // Fallback for unknown violations
            return ViolationModel(
              violationName: entry.key,
              repetition: 1,
              price: 1000.0,
              selectedOption: null,
              excessPassengers: null,
              additionalDetails: null,
            );
          }
        })
        .toList();
  }

  /// Convert selected violations with custom data
  static List<ViolationModel> fromSelectedViolationsWithData(Map<String, dynamic> selectedViolations) {
    return selectedViolations.entries
        .where((entry) => entry.value is Map<String, dynamic>) // Custom data violations
        .map((entry) {
          final violationDef = definitions[entry.key];
          final violationData = entry.value as Map<String, dynamic>;
          
          if (violationDef != null) {
            return ViolationModel(
              violationName: violationDef.displayName,
              repetition: violationData['repetition'] ?? 1,
              price: violationData['price'] ?? violationDef.getDefaultPrice(),
              selectedOption: violationData['option'] as String?, // Capture selected option
              excessPassengers: violationData['excessPassengers'] as int?, // Capture excess passengers
              additionalDetails: _extractAdditionalDetails(violationData), // Extract any other details
            );
          } else {
            // Fallback for unknown violations
            return ViolationModel(
              violationName: entry.key,
              repetition: violationData['repetition'] ?? 1,
              price: violationData['price'] ?? 1000.0,
              selectedOption: violationData['option'] as String?,
              excessPassengers: violationData['excessPassengers'] as int?,
              additionalDetails: _extractAdditionalDetails(violationData),
            );
          }
        })
        .toList();
  }

  /// Extract additional details from violation data, excluding known fields
  static Map<String, dynamic>? _extractAdditionalDetails(Map<String, dynamic> violationData) {
    final knownFields = {'repetition', 'price', 'option', 'excessPassengers'};
    final additionalDetails = <String, dynamic>{};
    
    for (final entry in violationData.entries) {
      if (!knownFields.contains(entry.key)) {
        additionalDetails[entry.key] = entry.value;
      }
    }
    
    return additionalDetails.isEmpty ? null : additionalDetails;
  }

  /// Get default violations map for the bloc
  static Map<String, dynamic> getDefaultViolationsMap() {
    return definitions.map((key, value) => MapEntry(key, false));
  }
}

class ViolationDefinition {
  final String name;
  final String displayName;
  final ViolationType type;
  final Map<int, double>? prices; // For fixed pricing based on offense number
  final double? minPrice; // For range pricing
  final double? maxPrice; // For range pricing
  final List<String>? options; // For violations with multiple options
  final List<double>? optionPrices; // Prices corresponding to options
  final double? excessPassengerFee; // For calculated violations like overloading

  const ViolationDefinition({
    required this.name,
    required this.displayName,
    required this.type,
    this.prices,
    this.minPrice,
    this.maxPrice,
    this.options,
    this.optionPrices,
    this.excessPassengerFee,
  });

  double getDefaultPrice() {
    switch (type) {
      case ViolationType.fixed:
        return prices?[1] ?? 1000.0;
      case ViolationType.range:
        return minPrice ?? 1000.0;
      case ViolationType.calculated:
        return prices?[1] ?? 1000.0;
    }
  }

  double getPriceForOffense(int offenseNumber) {
    switch (type) {
      case ViolationType.fixed:
        return prices?[offenseNumber] ?? prices?[prices!.keys.last] ?? 1000.0;
      case ViolationType.range:
        return minPrice ?? 1000.0;
      case ViolationType.calculated:
        return prices?[offenseNumber] ?? prices?[prices!.keys.last] ?? 1000.0;
    }
  }

  bool requiresCustomInput() {
    return type == ViolationType.range || 
           (type == ViolationType.range && options != null) ||
           type == ViolationType.calculated;
  }
}
