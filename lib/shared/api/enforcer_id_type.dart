import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_id_type_model.dart';


Future<List<EnforcerIdTypeModel>> getEnforcerIdTypes() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('enforcer_id_type')
      .get();

  var types = snapshot.docs.map((doc) {
    final data = doc.data();
    final id = doc.id; // Get the document ID here
    return EnforcerIdTypeModel.fromJson(id, data);
  }).toList();

  return types;
}
