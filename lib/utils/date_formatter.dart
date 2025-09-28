import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _formatter = DateFormat('MMM dd, yyyy h:mma');
  
  static String format(DateTime dateTime) {
    return _formatter.format(dateTime);
  }
  
  static String formatNow() {
    return _formatter.format(DateTime.now());
  }
}