import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/app_theme/colors.dart';
import '../../shared/components/textfield/app_input_border.dart';
import '../../shared/models/response_model.dart';
import '../../shared/models/driver_model.dart';
import '../../utils/input_formatters.dart';
import 'driver_registration_service.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _driverRegistrationService = DriverRegistrationService();

  // Controllers for required fields
  final _plateNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Controllers for optional fields
  final _middleNameController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();

  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Initialize mobile number with +63 prefix
    _mobileNumberController.text = '+63';
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _middleNameController.dispose();
    _driverLicenseNumberController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }



  Future<void> _registerDriver() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      ResponseModel<DriverModel> response = await _driverRegistrationService.registerDriver(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        plateNumber: _plateNumberController.text.trim().toUpperCase(),
        mobileNumber: _mobileNumberController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty 
            ? null 
            : _middleNameController.text.trim(),
        driverLicenseNumber: _driverLicenseNumberController.text.trim().isEmpty 
            ? null 
            : _driverLicenseNumberController.text.trim(),
      );

      if (response.success) {
        _showSnackBar('Registration successful!');
        Navigator.pop(context);
      } else {
        _showSnackBar(response.message ?? 'Registration failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('An unexpected error occurred', isError: true);
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColor().secondary,
      appBar: AppBar(
        title: Text(
          'Driver Registration',
          style: TextStyle(color: MainColor().textPrimary),
        ),
        backgroundColor: MainColor().secondary,
        iconTheme: IconThemeData(color: MainColor().textPrimary),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Create Driver Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: MainColor().textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                
                // Required Fields Section
                Text(
                  'Required Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MainColor().textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                
                // Plate Number
                TextFormField(
                  controller: _plateNumberController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Plate Number *"),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8), // Max 8 characters for Philippine plates
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Plate number is required';
                    }
                    
                    if (value.trim().length > 8) {
                      return 'Plate number cannot exceed 8 characters';
                    }
                    
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("First Name *"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Last Name *"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Email *"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Mobile Number
                TextFormField(
                  controller: _mobileNumberController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Mobile Number *"),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    PhilippineMobileNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mobile number is required';
                    }
                    // Check if it's exactly 13 characters (+63 + 10 digits)
                    if (value.length != 13) {
                      return 'Mobile number must be exactly 10 digits after +63';
                    }
                    // Check if it starts with +63
                    if (!value.startsWith('+63')) {
                      return 'Mobile number must start with +63';
                    }
                    // Check if the part after +63 contains only digits
                    String digits = value.substring(3);
                    if (!RegExp(r'^\d{10}$').hasMatch(digits)) {
                      return 'Mobile number must contain exactly 10 digits after +63';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Password *").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: MainColor().textPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Confirm Password *").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: MainColor().textPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                
                // Optional Fields Section
                Text(
                  'Optional Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MainColor().textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                
                // Middle Name
                TextFormField(
                  controller: _middleNameController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Middle Name"),
                ),
                SizedBox(height: 16),
                
                // Driver License Number
                TextFormField(
                  controller: _driverLicenseNumberController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration("Driver License Number"),
                ),
                SizedBox(height: 32),
                
                // Register Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MainColor().accent,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                    ),
                    onPressed: _isRegistering ? null : _registerDriver,
                    child: _isRegistering
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Register Driver",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Back to Login Button
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: MainColor().textPrimary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
