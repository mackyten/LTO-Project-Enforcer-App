import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/enums/collections.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/pages/violation/models/violation_model.dart';
import 'package:enforcer_auto_fine/pages/violation/models/violations_config.dart';

/// Calculate repetition counts for violations based on previous reports for the same plate number
Future<List<ViolationModel>> _calculateViolationRepetitions(
  String plateNumber, 
  List<ViolationModel> newViolations
) async {
  try {
    final db = FirebaseFirestore.instance;
    
    // Get all previous reports for this plate number
    final previousReportsSnapshot = await db
        .collection(Collections.reports.name)
        .where('plateNumber', isEqualTo: plateNumber)
        .get();
    
    // Count existing violations for this plate number
    final Map<String, int> violationCounts = {};
    
    for (var doc in previousReportsSnapshot.docs) {
      final data = doc.data();
      final List<dynamic> violationsData = data['violations'] as List<dynamic>;
      
      for (var violationData in violationsData) {
        if (violationData is Map<String, dynamic>) {
          // New format with ViolationModel
          final violationName = violationData['violationName'] as String;
          violationCounts.update(
            violationName,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        } else if (violationData is String) {
          // Legacy format - just strings
          violationCounts.update(
            violationData,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }
    
    // Update repetition counts for new violations
    final List<ViolationModel> updatedViolations = newViolations.map((violation) {
      final existingCount = violationCounts[violation.violationName] ?? 0;
      return violation.copyWith(repetition: existingCount + 1);
    }).toList();

    // Update prices based on repetition for violations that have repetition-based pricing
    final List<ViolationModel> finalViolations = updatedViolations.map((violation) {
      final violationDef = ViolationsConfig.definitions.values
          .firstWhere(
            (def) => def.displayName == violation.violationName,
            orElse: () => const ViolationDefinition(
              name: 'other',
              displayName: 'Other',
              type: ViolationType.range,
              minPrice: 500.0,
              maxPrice: 100000.0,
            ),
          );
      
      // Only update price for fixed-price violations if the current price matches default
      if (violationDef.type == ViolationType.fixed && 
          violationDef.prices != null) {
        final newPrice = violationDef.getPriceForOffense(violation.repetition);
        return violation.copyWith(price: newPrice);
      }
      
      return violation;
    }).toList();
    
    return finalViolations;
  } catch (e) {
    print('Error calculating violation repetitions: $e');
    // Return original violations if calculation fails
    return newViolations;
  }
}

Future<String?> handleSave(ReportModel data) async {
  try {
    // Get an instance of Firestore
    final db = FirebaseFirestore.instance;

    // Calculate repetition counts for violations
    final updatedViolations = await _calculateViolationRepetitions(
      data.plateNumber,
      data.violations,
    );
    
    // Create updated report with correct repetition counts
    final updatedData = ReportModel(
      fullname: data.fullname,
      address: data.address,
      phoneNumber: data.phoneNumber,
      licenseNumber: data.licenseNumber,
      licensePhoto: data.licensePhoto,
      plateNumber: data.plateNumber,
      platePhoto: data.platePhoto,
      evidencePhoto: data.evidencePhoto,
      trackingNumber: data.trackingNumber,
      createdById: data.createdById,
      violations: updatedViolations,
      createdAt: data.createdAt,
      draftId: data.draftId,
    );

    // Convert your ReportModel to a Map
    final reportData = updatedData.toJson();

    // Add a new document with a generated ID to the 'reports' collection
    await db.collection(Collections.reports.name).add(reportData);

    print('Report successfully saved to Firestore!');
    var tNumber = ReportModel.fromJson(reportData).trackingNumber;

    return tNumber;
  } catch (e) {
    print('Error saving report to Firestore: $e');
    return null;
  }
}
