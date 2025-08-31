import 'package:enforcer_auto_fine/pages/auth/login/index.dart';
import 'package:enforcer_auto_fine/pages/home/home.dart';
import 'package:enforcer_auto_fine/pages/violation/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while the stream is waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if the user is authenticated (snapshot.hasData returns true if user is not null)
        if (snapshot.hasData) {
          // If the user is signed in, show the home page.`
          return const HomePage();
        } else {
          // If the user is not signed in, show the login page.
          return const LoginPage();
        }
      },
    );
  }
}