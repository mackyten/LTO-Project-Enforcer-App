import 'package:flutter/services.dart';

/// Custom input formatter for Philippine mobile numbers
/// Formats input as +63XXXXXXXXXX (13 characters total)
/// Automatically adds +63 prefix and limits to 10 digits after the prefix
class PhilippineMobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // If user tries to delete the +63, restore it
    if (digitsOnly.isEmpty || (digitsOnly.length < 2 && !digitsOnly.startsWith('63'))) {
      return TextEditingValue(
        text: '+63',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    
    // Ensure it starts with 63
    if (!digitsOnly.startsWith('63')) {
      digitsOnly = '63' + digitsOnly;
    }
    
    // Limit to 13 characters total (+63 + 10 digits)
    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }
    
    // Format as +63XXXXXXXXXX
    String formatted = '+$digitsOnly';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
