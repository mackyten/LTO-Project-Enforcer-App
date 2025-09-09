import 'package:enforcer_auto_fine/pages/auth/handlers.dart';
import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/components/side_drawer/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppMainSideDrawer extends StatefulWidget {
  const AppMainSideDrawer({super.key});

  @override
  State<AppMainSideDrawer> createState() => _AppMainSideDrawerState();
}

class _AppMainSideDrawerState extends State<AppMainSideDrawer> {
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
            var enforcerData = state.enforcerData;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(),
                        child: Wrap(
                          spacing: 10,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CircleAvatar(
                              radius:
                                  30, // radius is half the desired width/height
                              backgroundImage:
                                  enforcerData.profilePictureUrl.isNotEmpty
                                  ? NetworkImage(enforcerData.profilePictureUrl)
                                  : null,
                              child: enforcerData.profilePictureUrl.isEmpty
                                  ? Icon(Icons.account_circle, size: 50)
                                  : null,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  enforcerData.getFullName(),
                                  style: TextStyle(
                                    color: MainColor().textPrimary,
                                  ),
                                ),
                                Text(
                                  enforcerData.email,
                                  style: TextStyle(
                                    color: MainColor().textPrimary,
                                    fontSize: FontSizes().caption,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ...AppMainSideDrawerItem.items.map((item) {
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
                      }),
                    ],
                  ),
                ),
                Spacer(),
                ListTile(
                  textColor: MainColor().textPrimary,
                  iconColor: MainColor().textPrimary,
                  leading: isLoggingOut
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: MainColor()
                                .textPrimary, // Optional: customize the color
                          ),
                      )
                      : Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: () async {
                    // Check if we are already logging out to prevent multiple taps
                    if (isLoggingOut) return;

                    // Set the state to true to show the loading indicator
                    setState(() {
                      isLoggingOut = true;
                    });

                    try {
                      // Wait for the sign out operation to complete
                      await signOut();

                      // If sign out is successful, navigate to the login/landing page
                      // if (mounted) {
                      //   Navigator.of(context).pushNamedAndRemoveUntil(
                      //     '/auth', // Or your desired initial route
                      //     (Route<dynamic> route) => false,
                      //   );
                      // }
                    } catch (e) {
                      // Handle potential errors during sign out (e.g., network issues)
                      print("Sign out failed: $e");
                    } finally {
                      // This block will always execute, regardless of success or failure
                      if (mounted) {
                        setState(() {
                          isLoggingOut = false;
                        });
                      }
                    }
                  },
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
}
