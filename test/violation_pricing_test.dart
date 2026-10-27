import 'package:enforcer_auto_fine/pages/violation/models/violation_model.dart';
import 'package:enforcer_auto_fine/pages/violation/models/violations_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViolationDefinition pricing', () {
    final reckless = ViolationsConfig.definitions['reckless-driving']!;
    final noHelmet = ViolationsConfig.definitions['no-helmet']!;

    test('fixed violation escalates with repeat offenses', () {
      expect(reckless.getPriceForOffense(1), 2000.0);
      expect(reckless.getPriceForOffense(2), 3000.0);
      expect(reckless.getPriceForOffense(3), 10000.0);
    });

    test('offense beyond the table falls back to the last tier', () {
      expect(reckless.getPriceForOffense(9), 10000.0);
      expect(noHelmet.getPriceForOffense(9), 10000.0);
    });

    test('default price is the first-offense price', () {
      expect(reckless.getDefaultPrice(), 2000.0);
    });

    test('range violations require custom input, fixed ones do not', () {
      final parking = ViolationsConfig.definitions['illegal-parking']!;

      expect(parking.type, ViolationType.range);
      expect(parking.requiresCustomInput(), isTrue);
      expect(reckless.requiresCustomInput(), isFalse);
    });

    test('every configured violation has a name matching its key', () {
      ViolationsConfig.definitions.forEach((key, definition) {
        expect(definition.name, key);
        expect(definition.getDefaultPrice(), greaterThan(0));
      });
    });
  });

  group('ViolationModel', () {
    final model = ViolationModel(
      violationName: 'illegal-parking',
      repetition: 2,
      price: 2000,
      selectedOption: 'Unattended (₱2,000)',
    );

    test('toJson omits null optional fields', () {
      expect(model.toJson(), {
        'violationName': 'illegal-parking',
        'repetition': 2,
        'price': 2000.0,
        'selectedOption': 'Unattended (₱2,000)',
      });
    });

    test('fromJson(toJson) round-trips', () {
      expect(ViolationModel.fromJson(model.toJson()), model);
    });

    test('fromJson accepts integer prices', () {
      final parsed = ViolationModel.fromJson(
        {'violationName': 'no-helmet', 'repetition': 1, 'price': 1500},
      );

      expect(parsed.price, 1500.0);
    });

    test('copyWith changes only the given field', () {
      final copy = model.copyWith(repetition: 3);

      expect(copy.repetition, 3);
      expect(copy.violationName, model.violationName);
      expect(copy.price, model.price);
    });
  });
}
