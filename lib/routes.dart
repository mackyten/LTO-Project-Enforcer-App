import 'package:flutter/material.dart';
import 'pages/driver_violations/index.dart';

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/driver-violations':
        final plateNumber = settings.arguments as String?;
        if (plateNumber != null) {
          return MaterialPageRoute(
            builder: (context) => DriverViolationsPage(plateNumber: plateNumber),
          );
        }
        break;
    }
    return null;
  }
}
