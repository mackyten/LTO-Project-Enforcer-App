import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:flutter/material.dart';

BoxDecoration appBg = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MainColor().primary, MainColor().secondary, MainColor().tertiary],
  ),
);
