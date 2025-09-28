import 'violation_model.dart';

class ViolationsConfig {
  static const Map<String, ViolationDefinition> definitions = {
    'speeding': ViolationDefinition(
      name: 'speeding',
      displayName: 'Speeding',
      defaultPrice: 1500.0,
    ),
    'illegal-parking': ViolationDefinition(
      name: 'illegal-parking',
      displayName: 'Illegal Parking',
      defaultPrice: 500.0,
    ),
    'traffic-light': ViolationDefinition(
      name: 'traffic-light',
      displayName: 'Traffic Light Violation',
      defaultPrice: 2000.0,
    ),
    'reckless-driving': ViolationDefinition(
      name: 'reckless-driving',
      displayName: 'Reckless Driving',
      defaultPrice: 3000.0,
    ),
    'phone-use': ViolationDefinition(
      name: 'phone-use',
      displayName: 'Phone Use While Driving',
      defaultPrice: 1000.0,
    ),
    'no-seatbelt': ViolationDefinition(
      name: 'no-seatbelt',
      displayName: 'No Seatbelt',
      defaultPrice: 300.0,
    ),
    'other': ViolationDefinition(
      name: 'other',
      displayName: 'Other Violation',
      defaultPrice: 1000.0,
    ),
  };

  /// Convert selected violations from Map<String, bool> to List<ViolationModel>
  static List<ViolationModel> fromSelectedViolations(Map<String, bool> selectedViolations) {
    return selectedViolations.entries
        .where((entry) => entry.value) // Only selected violations
        .map((entry) {
          final violationDef = definitions[entry.key];
          if (violationDef != null) {
            return ViolationModel(
              violationName: violationDef.displayName,
              repetition: 1, // Default repetition
              price: violationDef.defaultPrice,
            );
          } else {
            // Fallback for unknown violations
            return ViolationModel(
              violationName: entry.key,
              repetition: 1,
              price: 1000.0,
            );
          }
        })
        .toList();
  }

  /// Get default violations map for the bloc
  static Map<String, bool> getDefaultViolationsMap() {
    return definitions.map((key, value) => MapEntry(key, false));
  }
}

class ViolationDefinition {
  final String name;
  final String displayName;
  final double defaultPrice;

  const ViolationDefinition({
    required this.name,
    required this.displayName,
    required this.defaultPrice,
  });
}
