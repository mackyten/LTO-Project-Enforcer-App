import 'package:flutter/material.dart';
import '../../../shared/app_theme/colors.dart';
import '../../../shared/app_theme/fonts.dart';
import '../../../pages/auth/handlers.dart';

class UnauthorizedPage extends StatefulWidget {
  const UnauthorizedPage({super.key});

  @override
  State<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Unauthorized Icon
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.block,
              size: 80,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 30),
          
          // Title
          Text(
            'Access Denied',
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
            'Admin Role Detected',
            style: TextStyle(
              fontSize: FontSizes().h4,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          
          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Text(
              'This mobile application is not intended for admin users. Please use the web dashboard to access admin features.',
              style: TextStyle(
                fontSize: FontSizes().body,
                color: MainColor().textPrimary.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
          SizedBox(height: 20),
          
          // Contact Info
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: MainColor().primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: MainColor().primary,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Need help? Contact your system administrator.',
                    style: TextStyle(
                      fontSize: FontSizes().caption,
                      color: MainColor().textPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
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
      await signOut();
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
