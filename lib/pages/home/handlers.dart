import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/pages/home/models.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/shared/models/user_model.dart' as UserModelWithRoles;
import 'package:enforcer_auto_fine/shared/models/driver_model.dart';
import 'package:enforcer_auto_fine/shared/models/response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../enums/collections.dart';
import '../../enums/user_roles.dart';

class HomeHandlers {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<WeekleySummaryModel> getWeeklySummary() async {
    // 1. Get total violations using the count() aggregation
    final totalViolationsSnapshot = await _db
        .collection('reports')
        .count()
        .get();
    final int totalViolations = totalViolationsSnapshot.count ?? 0;

    // 2. Get this week's violations
    final DateTime oneWeekAgo = DateTime.now().subtract(
      const Duration(days: 7),
    );
    final thisWeekSnapshot = await _db
        .collection('reports')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: oneWeekAgo.toIso8601String(),
        )
        .count()
        .get();
    final int thisWeeksViolation = thisWeekSnapshot.count ?? 0;

    // 3. Get top 5 most common violations
    final allViolationsSnapshot = await _db
        .collection(Collections.reports.name)
        .get();
    final List<String> allViolations = [];

    // Collect all violations from all documents
    for (var doc in allViolationsSnapshot.docs) {
      final data = doc.data();
      final List<String> violations = List<String>.from(data['violations']);
      allViolations.addAll(violations);
    }

    // Count the frequency of each violation
    final Map<String, int> violationCounts = {};
    for (String violation in allViolations) {
      violationCounts.update(
        violation,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    // Sort the violations by count in descending order
    final sortedViolations = violationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take the top 5 and map them to a list of ReportModel
    final List<CommonViolationModel> mostCommon = sortedViolations
        .take(5)
        .map((e) => CommonViolationModel(violationName: e.key, count: e.value))
        .toList();

    // Return the combined data in the WeeklySummaryModel
    return WeekleySummaryModel(
      totalViolations: totalViolations,
      thisWeeksViolation: thisWeeksViolation,
      mostCommon: mostCommon,
    );
  }

  Future<ResponseModel<UserModelWithRoles.UserModel>> fetchUserData() async {
    try {
      var response = ResponseModel<UserModelWithRoles.UserModel>(null, false, null);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        response.success = false;
        response.message = 'No authenticated user found';
      }
      final userUUID = currentUser?.uid;
      final collectionReference = _db.collection(Collections.users.name);
      final querySnapshot = await collectionReference
          .where('uuid', isEqualTo: userUUID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = UserModelWithRoles.UserModel.fromJson(querySnapshot.docs.first.data());
        response.data = data;
        response.success = true;
      } else {
        response.success = false;
        response.message = 'No user data found';
      }
      return response;
    } catch (e) {
      return ResponseModel(null, false, 'Error fetching user data: $e');
    }
  }

  Future<List<ReportModel>> loadAllReportDrafts() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all keys and filter for those that start with 'draft_'
    final draftKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('draft_'))
        .toList();

    final List<ReportModel> drafts = [];

    // Iterate through the keys and load each draft
    for (final key in draftKeys) {
      final String? draftJson = prefs.getString(key);
      if (draftJson != null) {
        final Map<String, dynamic> draftMap = jsonDecode(draftJson);
        drafts.add(ReportModel.fromJson(draftMap));
      }
    }

    return drafts;
  }

  Future<ResponseModel<UserModelWithRoles.UserModel>> fetchUserDataWithRoles() async {
    try {
      var response = ResponseModel<UserModelWithRoles.UserModel>(null, false, null);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        response.success = false;
        response.message = 'No authenticated user found';
        return response;
      }
      final userUUID = currentUser.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(userUUID);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        var data = UserModelWithRoles.UserModel.fromJson(docSnapshot.data()!);
        response.data = data;
        response.success = true;
      } else {
        response.success = false;
        response.message = 'No user data found';
      }

      return response;
    } catch (e) {
      var response = ResponseModel<UserModelWithRoles.UserModel>(null, false, e.toString());
      return response;
    }
  }

  /// Enhanced method that returns typed user data based on roles
  Future<ResponseModel<UserModelWithRoles.UserModel>> fetchTypedUserData() async {
    try {
      var response = ResponseModel<UserModelWithRoles.UserModel>(null, false, null);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        response.success = false;
        response.message = 'No authenticated user found';
        return response;
      }
      
      final userUUID = currentUser.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(userUUID);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        response.success = false;
        response.message = 'No user data found';
        return response;
      }

      // Get the raw data from Firestore
      final rawData = docSnapshot.data()!;
      
      // Parse roles to determine user type
      final rolesList = rawData['roles'] as List<dynamic>?;
      final roles = rolesList?.map((role) => UserRoles.values.firstWhere(
            (e) => e.toString().split('.').last == role,
            orElse: () => UserRoles.None,
          )).toList() ?? [];
      
      // Check if user is a driver [UserRoles.None, UserRoles.Driver]
      if (roles.length == 2 && 
          roles.contains(UserRoles.None) && 
          roles.contains(UserRoles.Driver)) {
        // Create DriverModel directly from raw Firestore data
        final driverData = DriverModel.fromJson(rawData);
        return ResponseModel<UserModelWithRoles.UserModel>(driverData, true, null);
      }
      
      // Check if user is an enforcer [UserRoles.None, UserRoles.Enforcer]  
      if (roles.length == 2 && 
          roles.contains(UserRoles.None) && 
          roles.contains(UserRoles.Enforcer)) {
        // Create EnforcerModel directly from raw Firestore data
        final enforcerData = EnforcerModel.fromJson(rawData);
        return ResponseModel<UserModelWithRoles.UserModel>(enforcerData, true, null);
      }
      
      // For any other role combination, return the base user data
      final userData = UserModelWithRoles.UserModel.fromJson(rawData);
      return ResponseModel<UserModelWithRoles.UserModel>(userData, true, null);
      
    } catch (e) {
      return ResponseModel<UserModelWithRoles.UserModel>(null, false, e.toString());
    }
  }
}
