import 'package:flutter/material.dart';
import '../../../shared/app_theme/colors.dart';
import '../../../shared/app_theme/fonts.dart';
import '../../../pages/auth/handlers.dart';
import '../../../enums/user_roles.dart';

class RoleErrorPage extends StatefulWidget {
  final List<UserRoles> userRoles;

  const RoleErrorPage({super.key, required this.userRoles});

  @override
  State<RoleErrorPage> createState() => _RoleErrorPageState();
}

class _RoleErrorPageState extends State<RoleErrorPage> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 30),
          
          // Title
          Text(
            'Account Configuration Error',
            style: TextStyle(
              fontSize: FontSizes().h2,
              fontWeight: FontWeight.bold,
              color: MainColor().textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          
          // Subtitle
          Text(
            'Multiple Roles Detected',
            style: TextStyle(
              fontSize: FontSizes().h4,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          
          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'Your account has been assigned too many roles (${widget.userRoles.length} roles). This configuration is not supported by the mobile application.',
                  style: TextStyle(
                    fontSize: FontSizes().body,
                    color: MainColor().textPrimary.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'Current Roles:',
                  style: TextStyle(
                    fontSize: FontSizes().body,
                    fontWeight: FontWeight.w600,
                    color: MainColor().textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.userRoles.map((role) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role.toString().split('.').last,
                        style: TextStyle(
                          fontSize: FontSizes().caption,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: MainColor().primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: MainColor().primary,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'What to do:',
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          fontWeight: FontWeight.w600,
                          color: MainColor().primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '1. Contact your system administrator\n'
                  '2. Request role configuration review\n'
                  '3. Ensure only appropriate roles are assigned',
                  style: TextStyle(
                    fontSize: FontSizes().caption,
                    color: MainColor().textPrimary.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
              ),
              onPressed: isLoggingOut ? null : _handleLogout,
              icon: isLoggingOut
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.logout),
              label: Text(
                isLoggingOut ? 'Logging out...' : 'Logout',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      isLoggingOut = true;
    });

    try {
      await signOut(context);
    } catch (e) {
      print("Sign out failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }
}
