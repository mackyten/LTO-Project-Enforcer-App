import 'package:enforcer_auto_fine/enums/user_roles.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_theme/colors.dart';
import '../../../shared/app_theme/fonts.dart';
import '../../../shared/models/driver_model.dart';

class DriverHomePage extends StatelessWidget {
  final DriverModel userData;

  const DriverHomePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(child: Container()),
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MainColor().primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            userData.profilePictureUrl?.isNotEmpty == true
                            ? NetworkImage(userData.profilePictureUrl!)
                            : null,
                        child: userData.profilePictureUrl?.isEmpty ?? true
                            ? Icon(Icons.account_circle, size: 50)
                            : null,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: FontSizes().caption,
                                color: MainColor().textPrimary.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${userData.firstName} ${userData.lastName}',
                              style: TextStyle(
                                fontSize: FontSizes().h3,
                                fontWeight: FontWeight.bold,
                                color: MainColor().textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MainColor().accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car, color: MainColor().accent),
                        SizedBox(width: 10),
                        Text(
                          'Driver Account',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.w600,
                            color: MainColor().accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: FontSizes().h4,
                fontWeight: FontWeight.bold,
                color: MainColor().textPrimary,
              ),
            ),
            SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  icon: Icons.receipt_long,
                  title: 'My Violations',
                  subtitle: 'View violation history',
                  color: Colors.red,
                  onTap: () {
                    // Access plateNumber directly since userData is already DriverModel
                    if (userData.roles!.contains(UserRoles.Driver)) {
                      if (userData.plateNumber != null) {
                        Navigator.pushNamed(
                          context,
                          '/driver-violations',
                          arguments: userData.plateNumber!,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Plate number not found. Please update your profile.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to access driver information. Please try again.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.payment,
                  title: 'Pay Fines',
                  subtitle: 'Pay outstanding fines',
                  color: Colors.green,
                  onTap: () {
                    // Navigate to payment
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.person,
                  title: 'My Profile',
                  subtitle: 'Update personal info',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.gavel,
                  title: 'File an Appeal',
                  subtitle: 'Appeal a violation',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, '/appeal');
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.format_list_bulleted,
                  title: 'My Appeals',
                  subtitle: 'View appeal status',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, '/driver-appeals');
                  },
                ),
              ],
            ),
            SizedBox(height: 25),

            // Notice Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Important Notice',
                        style: TextStyle(
                          fontSize: FontSizes().h4,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Always follow traffic rules and regulations. Keep your driver\'s license and vehicle registration up to date.',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      color: MainColor().textPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: FontSizes().body,
                fontWeight: FontWeight.bold,
                color: MainColor().textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: FontSizes().caption,
                color: MainColor().textPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
