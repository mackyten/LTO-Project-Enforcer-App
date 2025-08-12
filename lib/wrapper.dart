import 'package:enforcer_auto_fine/pages/home/index.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {



  @override
  Widget build(BuildContext context) {
    bool isAuthenticated = true;
    if (isAuthenticated) {
        return Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: const RouteSettings(name: '/home'),
          );
        },
      );
    } else {    
      return const Placeholder();
    }
  }
}