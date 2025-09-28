import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/home/components/pendings.dart';
import 'package:enforcer_auto_fine/pages/home/components/weekly_summary.dart';
import 'package:enforcer_auto_fine/pages/home/components/driver_home_page.dart';
import 'package:enforcer_auto_fine/pages/home/components/unauthorized_page.dart';
import 'package:enforcer_auto_fine/pages/home/components/role_error_page.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/components/app_bar/index.dart';
import 'package:enforcer_auto_fine/shared/components/side_drawer/role_based_drawer.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/enums/user_roles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/greetings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the event to start fetching data
    context.read<HomeBloc>().add(FetchHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassmorphismAppBar(),
      drawer: RoleBasedSideDrawer(),
      floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            // Only show FAB for enforcers
            if (state.isEnforcer) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/violations');
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Icon(Icons.add),
              );
            }
          }
          return SizedBox.shrink(); // Hide FAB for non-enforcers
        },
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appBg,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial || state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is HomeLoaded) {
              // Determine which home page to show based on user roles
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(FetchHomeData());
                },
                child: _buildRoleBasedHome(state),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRoleBasedHome(HomeLoaded state) {
    final userRoles = state.userRoles;
    
    // Check role conditions using enhanced state methods
    if (userRoles.length > 3) {
      // Too many roles - show error page
      return RoleErrorPage(userRoles: userRoles);
    } else if (state.isDriver) {
      // Driver user - show driver home with properly typed data
      return DriverHomePage(userData: state.driverData!);
    } else if (state.isEnforcer) {
      // Enforcer user - show current home
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(child: Container()),
              Greetings(
                firstName: state.userData!.firstName,
                profilePictureUrl: state.profilePictureUrl,
              ),
              SizedBox(height: 20),
              WeeklySummary(weekleySummary: state.weeklySummary),
              SizedBox(height: 20),
              Pendings(onLongPressed: onLongPressed),
            ],
          ),
        ),
      );
    } else if (state.isAdmin) {
      // Admin user - show unauthorized page
      return UnauthorizedPage();
    } else {
      // Unknown role configuration - show error
      return RoleErrorPage(userRoles: userRoles);
    }
  }

  void onLongPressed(ReportModel report) {
    showModalBottomSheet(
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return IntrinsicHeight(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  "Are you sure want to delete?",
                  style: TextStyle(
                    fontSize: FontSizes().h4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: MainColor().error, // Change the color here
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  iconAlignment: IconAlignment.start,
                ),

                Divider(),

                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        MainColor().primary, // Change the color here
                  ),
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  label: const Text('Cancel'),
                  iconAlignment: IconAlignment.start,
                ),
                Divider(color: Colors.transparent),
              ],
            ),
          ),
        );
      },
    );
  }
}
