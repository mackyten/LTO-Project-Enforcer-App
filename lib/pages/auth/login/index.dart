import 'package:enforcer_auto_fine/pages/auth/handlers.dart';
import 'package:enforcer_auto_fine/pages/auth/login/components/poligon_clipper.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/app_input_border.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoggingIn = false;

  @override
  void initState() {
    _emailController.text = "testuser@mailinator.com";
    _passwordController.text = "P@ssword1";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height,
            color: MainColor().secondary,
          ),

          // 1. The first clipped shape (positioned at the top-left)
          Positioned(
            top: 0, // Adjust these values to position the shapes as needed
            left: 0, //
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: Transform.rotate(
                angle: 0, //-5 * math.pi / 180, // A slight negative rotation
                child: ClipPath(
                  clipper: PolygonClipper(),
                  child: Container(
                    width: 200,
                    height: 200,
                    color: MainColor().tertiary,
                  ),
                ),
              ),
            ),
          ),

          // 2. The second clipped shape (diagonally spaced)
          Positioned(
            top: 50, // 100 pixels down from the first shape's top
            left: 50, // 100 pixels right from the first shape's left
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: Transform.rotate(
                angle: 0, //-5 * math.pi / 180,
                child: ClipPath(
                  clipper: PolygonClipper(),
                  child: Container(
                    width: 200,
                    height: 200,
                    color: MainColor().tertiary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // 3. The third clipped shape (diagonally spaced)
          Positioned(
            top: 100, // 100 pixels down from the second shape's top
            left: 100, // 100 pixels right from the second shape's left

            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: Transform.rotate(
                angle: 0, //-5 * math.pi / 180,
                child: ClipPath(
                  clipper: PolygonClipper(),
                  child: Container(
                    width: 200,
                    height: 200,
                    color: MainColor().tertiary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content (Login Form, Buttons, etc.)
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: MainColor().textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    SizedBox(height: 63),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: MainColor().textPrimary),

                      decoration: appInputDecoration("Email"),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      obscureText: true,
                      controller: _passwordController,
                      style: TextStyle(color: MainColor().textPrimary),
                      decoration: appInputDecoration("Password"),
                    ),

                    SizedBox(height: 48),

                    SizedBox(
                      width: (screenSize.width * .75),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MainColor().accent,
                          fixedSize: Size.fromHeight(50),
                          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.5),
                        ),
                        onPressed: isLoggingIn
                            ? null
                            : () {
                                setState(() {
                                  isLoggingIn = true;
                                });
                                signInWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              },
                        child: isLoggingIn
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Login"),
                      ),
                    ),

                    SizedBox(height: 48),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: MainColor().textPrimary,
                      ),
                      onPressed: () {},
                      child: Text("Forgot password"),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: MainColor().accent,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/driver-registration');
                      },
                      child: Text("Driver Registration"),
                    ),
                    // Add your other login widgets here
                    // e.g., TextFields, "or connect with", Social buttons, etc.
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
