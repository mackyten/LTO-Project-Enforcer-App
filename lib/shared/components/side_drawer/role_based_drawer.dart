import 'package:flutter/material.dart';
import '../../../pages/auth/handlers.dart';
import '../../../pages/home/bloc/home_bloc.dart';
import '../../../shared/app_theme/colors.dart';
import '../../../shared/app_theme/fonts.dart';
import '../../../enums/user_roles.dart';
import 'items.dart';
import 'driver_items.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleBasedSideDrawer extends StatefulWidget {
  const RoleBasedSideDrawer({super.key});

  @override
  State<RoleBasedSideDrawer> createState() => _RoleBasedSideDrawerState();
}

class _RoleBasedSideDrawerState extends State<RoleBasedSideDrawer> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MainColor().secondary,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is HomeLoaded) {
            var userData = state.isDriver
                ? state.driverData!
                : state.enforcerData;
            var userRoles = userData?.roles ?? [];

            // Determine which drawer items to show based on roles
            List<Widget> drawerItems = [];

            if (_isDriver(userRoles)) {
              // Driver-specific items
              drawerItems = DriverSideDrawerItem.items.map((item) {
                return ListTile(
                  textColor: MainColor().textPrimary,
                  iconColor: MainColor().textPrimary,
                  leading: item.icon,
                  title: Text(item.title),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      item.route,
                      (Route<dynamic> route) => false,
                    );
                  },
                );
              }).toList();
            } else if (_isEnforcer(userRoles)) {
              // Enforcer-specific items (current items)
              drawerItems = AppMainSideDrawerItem.items.map((item) {
                return ListTile(
                  textColor: MainColor().textPrimary,
                  iconColor: MainColor().textPrimary,
                  leading: item.icon,
                  title: Text(item.title),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      item.route,
                      (Route<dynamic> route) => false,
                    );
                  },
                );
              }).toList();
            } else {
              // For admin or role error cases, show minimal items
              drawerItems = [
                ListTile(
                  textColor: MainColor().textPrimary,
                  iconColor: MainColor().textPrimary,
                  leading: Icon(Icons.person),
                  title: Text("Profile"),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/profile',
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ];
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // User Header
                      DrawerHeader(
                        decoration: BoxDecoration(),
                        child: Wrap(
                          spacing: 10,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  userData?.profilePictureUrl?.isNotEmpty == true
                                  ? NetworkImage(userData!.profilePictureUrl!)
                                  : null,
                              child: userData?.profilePictureUrl?.isEmpty ?? true
                                  ? Icon(Icons.account_circle, size: 50)
                                  : null,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${userData?.firstName} ${userData?.lastName}',
                                  style: TextStyle(
                                    color: MainColor().textPrimary,
                                  ),
                                ),
                                Text(
                                  userData?.email ?? '',
                                  style: TextStyle(
                                    color: MainColor().textPrimary,
                                    fontSize: FontSizes().caption,
                                  ),
                                ),
                                // Show role indicator
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(
                                      userRoles,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getRoleDisplayName(userRoles),
                                    style: TextStyle(
                                      color: _getRoleColor(userRoles),
                                      fontSize: FontSizes().caption - 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Dynamic drawer items based on role
                      ...drawerItems,
                    ],
                  ),
                ),
                // Logout Button
                ListTile(
                  textColor: MainColor().textPrimary,
                  iconColor: MainColor().textPrimary,
                  leading: isLoggingOut
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: MainColor().textPrimary,
                          ),
                        )
                      : Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: _handleLogout,
                ),
                SafeArea(child: SizedBox()),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  bool _isDriver(List<UserRoles> roles) {
    return roles.length == 2 &&
        roles.contains(UserRoles.None) &&
        roles.contains(UserRoles.Driver);
  }

  bool _isEnforcer(List<UserRoles> roles) {
    return roles.length == 2 &&
        roles.contains(UserRoles.None) &&
        roles.contains(UserRoles.Enforcer);
  }

  String _getRoleDisplayName(List<UserRoles> roles) {
    if (_isDriver(roles)) return 'Driver';
    if (_isEnforcer(roles)) return 'Enforcer';
    if (roles.contains(UserRoles.Admin)) return 'Admin';
    if (roles.length > 3) return 'Multiple Roles';
    return 'Unknown';
  }

  Color _getRoleColor(List<UserRoles> roles) {
    if (_isDriver(roles)) return Colors.blue;
    if (_isEnforcer(roles)) return Colors.green;
    if (roles.contains(UserRoles.Admin)) return Colors.red;
    if (roles.length > 3) return Colors.orange;
    return Colors.grey;
  }

  Future<void> _handleLogout() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await signOut();
    } catch (e) {
      print("Sign out failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }
}
