import 'package:enforcer_auto_fine/pages/auth/login/components/poligon_clipper.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/app_input_border.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../enums/user_roles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoggingIn = false;
  String? errorMessage;

  // @override
  // void initState() {
  //   _emailController.text = "testuser@mailinator.com";
  //   _passwordController.text = "P@ssword1";
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              child: SingleChildScrollView(
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

                    // Error message display
                    if (errorMessage != null) ...[
                      Container(
                        width: (screenSize.width * .75),
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

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
                            : () async {
                                setState(() {
                                  isLoggingIn = true;
                                  errorMessage = null; // Clear previous error
                                });
                                
                                try {
                                  await _performSignIn(_emailController.text.trim(), _passwordController.text);
                                  // Sign-in successful - the wrapper will handle navigation
                                } on FirebaseAuthException catch (e) {
                                  // Handle Firebase auth specific errors
                                  String message = _getFirebaseAuthErrorMessage(e);
                                  setState(() {
                                    errorMessage = message;
                                    isLoggingIn = false;
                                  });
                                } catch (e) {
                                  // Handle other errors
                                  setState(() {
                                    errorMessage = e.toString().replaceAll('Exception: ', '');
                                    isLoggingIn = false;
                                  });
                                }
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

  /// Enhanced sign-in method that handles temporary passwords for Enforcers
  Future<void> _performSignIn(String email, String password) async {
    try {
      // Try normal Firebase Auth sign-in first
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // If auth fails with invalid-credential, check for temporary password
      if (e.code == 'user-not-found') {
        print('User not found in Firebase Auth, checking Firestore...');
        
        // Check Firestore for temporary password
        final usersRef = FirebaseFirestore.instance.collection('users');
        final query = usersRef.where('email', isEqualTo: email);
        final snapshot = await query.get();

        if (snapshot.docs.isNotEmpty) {
          final userDoc = snapshot.docs.first;
          final userData = userDoc.data();

          // Check if user is an Enforcer with null uuid
          final roles = userData['roles'] as List<dynamic>? ?? [];
          final uuid = userData['uuid'];
          final temporaryPassword = userData['temporaryPassword'];

          // Validate conditions: uuid is null, roles contains only Enforcer, temp password matches
          if (uuid == null && 
              roles.length == 1 && 
              roles.contains(UserRoles.Enforcer.index) &&
              temporaryPassword == password) {
            
            // Create Firebase Auth account
            final newUserCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            final newUuid = newUserCredential.user?.uid;
            
            if (newUuid == null) {
              throw Exception('Failed to create user account');
            }

            // Update Firestore document
            await userDoc.reference.update({
              'uuid': newUuid,
              'temporaryPassword': FieldValue.delete(),
              'roles': [UserRoles.None.index, UserRoles.Enforcer.index],
            });

            print('Successfully created account for Enforcer: $email');
            return; // Success, let wrapper handle navigation
          } else {
            // Conditions not met, throw original error
            throw Exception('Invalid credentials or account not properly configured');
          }
        } else {
          // No user found in Firestore, throw original error
          throw Exception('No account found with this email address');
        }
      } else {
        // Other auth errors, rethrow
        throw e;
      }
    }
  }

  /// Get user-friendly error messages for Firebase Auth errors
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return e.message ?? 'Login failed';
    }
  }
}
