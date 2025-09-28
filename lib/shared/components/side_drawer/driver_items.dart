import 'package:flutter/material.dart';

class DriverSideDrawerItem {
  String title;
  String? caption;
  Widget icon;
  String route;

  DriverSideDrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    this.caption,
  });

  static List<DriverSideDrawerItem> items = [
    DriverSideDrawerItem(
      title: "Profile",
      icon: Icon(Icons.person),
      route: '/profile',
    ),
    DriverSideDrawerItem(
      title: "My Violations",
      icon: Icon(Icons.receipt_long),
      route: '/driver-violations',
    ),
    DriverSideDrawerItem(
      title: "Pay Fines",
      icon: Icon(Icons.payment),
      route: '/driver-payments',
    ),
  ];
}
