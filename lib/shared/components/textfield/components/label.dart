import 'package:flutter/material.dart';

class AppTextFieldLabel extends StatelessWidget {
  final String? label;
  final bool required;

  const AppTextFieldLabel({super.key, this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFFF3B30)),
                ),
              ]
            : [],
      ),
    );
  }
}
