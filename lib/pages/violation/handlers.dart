import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/enums/collections.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';

Future<bool> handleSave(ReportModel data) async {
  try {
    // Get an instance of Firestore
    final db = FirebaseFirestore.instance;

    // Convert your ReportModel to a Map
    final reportData = data.toJson();

    // Add a new document with a generated ID to the 'reports' collection
    await db.collection(Collections.reports.name).add(reportData);

    print('Report successfully saved to Firestore!');
    return true;
  } catch (e) {
    print('Error saving report to Firestore: $e');
    return false;
  }
}
