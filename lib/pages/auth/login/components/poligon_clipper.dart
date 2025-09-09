import 'package:flutter/material.dart';

class PolygonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Convert percentage coordinates from CSS to Flutter pixel coordinates
    final path = Path()
      ..moveTo(size.width * 1.00, size.height * 0.00) // 100% 0
      ..lineTo(size.width * 1.00, size.height * 0.17) // 100% 17%
      ..lineTo(size.width * 0.39, size.height * 0.45) // 39% 45%
      ..lineTo(size.width * 0.62, size.height * 0.64) // 62% 64%
      ..lineTo(size.width * 0.00, size.height * 1.00) // 0 100%
      ..lineTo(size.width * 0.00, size.height * 0.87) // 0 87%
      ..lineTo(size.width * 0.00, size.height * 0.00) // 0 0
      ..close(); // Connects the last point to the first
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}