import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:flutter/material.dart';

class TitleBuilder extends StatelessWidget {
  final String title;
  final Icon icon;
  const TitleBuilder({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: FontSizes().h3,
            fontWeight: FontWeight.bold,
            color: MainColor().secondary,
          ),
        ),
      ],
    );
  }
}
