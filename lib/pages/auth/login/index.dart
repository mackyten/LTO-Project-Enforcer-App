import 'package:enforcer_auto_fine/pages/auth/handlers.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:  SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Login Page',
                  style: TextStyle(fontSize: 24),
                ),
                ElevatedButton(onPressed: (){
                  signInWithEmailAndPassword("testuser@mailinator.com", "password123");
                }, child: Text("Login"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}