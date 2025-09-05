import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/home/components/pendings.dart';
import 'package:enforcer_auto_fine/pages/home/components/weekly_summary.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
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
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/violations');
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(12),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Icon(Icons.add), // The icon
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
              // Wrap the loaded content in a RefreshIndicator
              return RefreshIndicator(
                onRefresh: () async {
                  // This is the function that is called when the user pulls to refresh.
                  // Dispatch the event to reload the data.
                  context.read<HomeBloc>().add(FetchHomeData());
                },
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Greetings(
                            firstName: state.enforcerData.firstName,
                            profilePictureUrl:
                                state.enforcerData.profilePictureUrl,
                          ),
                          SizedBox(height: 20),
                          WeeklySummary(weekleySummary: state.weeklySummary),
                          SizedBox(height: 20),
                          Pendings(onLongPressed: onLongPressed),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void onLongPressed() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: const Center(child: Text('This is a Bottom Modal Sheet!')),
        );
      },
    );
  }
}
