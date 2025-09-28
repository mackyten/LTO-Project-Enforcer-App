import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appeal/models/appeal_model.dart';

class DriverAppealsHandlers {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get paginated appeals for the current driver
  Future<QuerySnapshot> getDriverAppeals({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    Query query = _db
        .collection('appeals')
        .where('createdById', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  /// Get total count of appeals for the current driver
  Future<int> getDriverAppealsCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final countSnapshot = await _db
        .collection('appeals')
        .where('createdById', isEqualTo: currentUser.uid)
        .count()
        .get();

    return countSnapshot.count ?? 0;
  }

  /// Get appeals count by status for the current driver
  Future<Map<String, int>> getAppealsCountByStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final appealsSnapshot = await _db
        .collection('appeals')
        .where('createdById', isEqualTo: currentUser.uid)
        .get();

    Map<String, int> statusCounts = {
      'pending': 0,
      'approved': 0,
      'rejected': 0,
    };

    for (var doc in appealsSnapshot.docs) {
      final appeal = AppealModel.fromJson(doc.data());
      statusCounts[appeal.status] = (statusCounts[appeal.status] ?? 0) + 1;
    }

    return statusCounts;
  }

  /// Delete an appeal (if allowed)
  Future<void> deleteAppeal(String appealId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Check if the appeal belongs to the current user
    final appealDoc = await _db.collection('appeals').doc(appealId).get();
    if (!appealDoc.exists) {
      throw Exception('Appeal not found');
    }

    final appeal = AppealModel.fromJson(appealDoc.data()!);
    if (appeal.createdById != currentUser.uid) {
      throw Exception('Unauthorized to delete this appeal');
    }

    // Only allow deletion if status is pending
    if (appeal.status != 'pending') {
      throw Exception('Can only delete pending appeals');
    }

    await _db.collection('appeals').doc(appealId).delete();
  }
}
