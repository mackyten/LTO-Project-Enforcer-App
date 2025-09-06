import 'dart:ui';
import 'package:flutter/material.dart';

// Assuming you have a file with your custom colors
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart'; 

class GlassmorphismAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;

  const GlassmorphismAppBar({
    super.key,
    this.title,
    this.actions, this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AppBar(
            title: title,
            centerTitle: true,
            leading: leading,
            actions: actions,
            elevation: 0.0,
            backgroundColor: Colors.black.withOpacity(0.2),
            foregroundColor: MainColor().textPrimary,
          ),
        ),
      ),
    );
  }
}