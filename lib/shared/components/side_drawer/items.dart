import 'package:flutter/material.dart';

class AppMainSideDrawerItem {
  String title;
  String? caption;
  Widget icon;
  String route;

  AppMainSideDrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    this.caption,
  });

  static List<AppMainSideDrawerItem> items = [
    AppMainSideDrawerItem(
      title: "Profile",
      icon: Icon(Icons.person),
      route: '/profile',
    ),
    AppMainSideDrawerItem(
      title: "New Report",
      icon: Icon(Icons.add),
      route: '/violations',
    ),
  ];
}
