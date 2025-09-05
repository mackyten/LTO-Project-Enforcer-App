import 'package:shared_preferences/shared_preferences.dart';

Future<void> deletePreference(String draftKey) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(draftKey);
  print('Draft with key "$draftKey" has been deleted.');
}