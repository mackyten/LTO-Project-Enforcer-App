import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:flutter/material.dart';

InputDecoration appInputDecoration(String? label) {
  return InputDecoration(
    label: Text(label ?? ''),
    labelStyle: TextStyle(color: MainColor().textPrimary),
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Color(0xFFFF3B30), width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );
}
