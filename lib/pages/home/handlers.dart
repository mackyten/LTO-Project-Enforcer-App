import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/shared/models/response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../enums/collections.dart';

Future<ResponseModel<EnforcerModel>> fetchUserData() async {
  try {
    var response = ResponseModel<EnforcerModel>(null, false, null);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      response.success = false;
      response.message = 'No authenticated user found';
    }
    final userUUID = currentUser?.uid;
    final collectionReference = FirebaseFirestore.instance.collection(
      Collections.enforcers.name,
    );
    final querySnapshot = await collectionReference
        .where('uuid', isEqualTo: userUUID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var data = EnforcerModel.fromJson(querySnapshot.docs.first.data());
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
