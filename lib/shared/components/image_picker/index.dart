import 'dart:io';
import 'package:flutter/material.dart';

class AppImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  final String icon;
  final String text;
  final String subtext;
  const AppImagePicker({
    super.key,
    this.image,
    required this.onTap,
    required this.icon,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: image != null
              ? Color(0xFF30D158).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null
                ? Color(0xFF30D158)
                : Colors.white.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (image == null) ...[
              Text(icon, style: TextStyle(fontSize: 40)),
              SizedBox(height: 12),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtext,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ] else ...[
              Icon(Icons.check_circle, color: Color(0xFF30D158), size: 40),
              SizedBox(height: 12),
              Text(
                '✅ Image selected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Tap to change',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
