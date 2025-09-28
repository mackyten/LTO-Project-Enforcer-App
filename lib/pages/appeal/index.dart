import 'package:flutter/material.dart';
import '../../shared/app_theme/colors.dart';
import '../../shared/app_theme/fonts.dart';
import '../../shared/decorations/app_bg.dart';
import '../../shared/components/textfield/app_input_border.dart';

class AppealPage extends StatefulWidget {
  const AppealPage({super.key});

  @override
  State<AppealPage> createState() => _AppealPageState();
}

class _AppealPageState extends State<AppealPage> {
  final _formKey = GlobalKey<FormState>();
  final _violationNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedAppealType = 'wrongful_citation';
  bool _isSubmitting = false;

  final List<Map<String, String>> _appealTypes = [
    {'value': 'wrongful_citation', 'label': 'Wrongful Citation'},
    {'value': 'incorrect_amount', 'label': 'Incorrect Fine Amount'},
    {'value': 'vehicle_misidentification', 'label': 'Vehicle Misidentification'},
    {'value': 'procedural_error', 'label': 'Procedural Error'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _violationNumberController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        title: Text(
          'File an Appeal',
          style: TextStyle(
            fontSize: FontSizes().h3,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appBg,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel,
                          color: Colors.blue,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Appeal a Violation',
                          style: TextStyle(
                            fontSize: FontSizes().h4,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'If you believe a violation was issued in error, you can file an appeal. Please provide all necessary details and supporting information.',
                      style: TextStyle(
                        fontSize: FontSizes().body,
                        color: MainColor().textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Violation Number
              Text(
                'Violation Number *',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                  color: MainColor().textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _violationNumberController,
                style: TextStyle(color: MainColor().textPrimary),
                decoration: appInputDecoration('Violation Number').copyWith(
                  hintText: 'Enter violation number (e.g., VIO-2024-001)',
                  prefixIcon: Icon(Icons.receipt_long, color: MainColor().textPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the violation number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Appeal Type
              Text(
                'Appeal Type *',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                  color: MainColor().textPrimary,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAppealType,
                dropdownColor: MainColor().secondary,
                style: TextStyle(color: MainColor().textPrimary),
                decoration: appInputDecoration('Appeal Type').copyWith(
                  prefixIcon: Icon(Icons.category, color: MainColor().textPrimary),
                ),
                items: _appealTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(
                      type['label']!,
                      style: TextStyle(color: MainColor().textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAppealType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an appeal type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Reason for Appeal
              Text(
                'Reason for Appeal *',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                  color: MainColor().textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                style: TextStyle(color: MainColor().textPrimary),
                decoration: appInputDecoration('Reason for Appeal').copyWith(
                  hintText: 'Brief reason for your appeal',
                  prefixIcon: Icon(Icons.edit, color: MainColor().textPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason for your appeal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Detailed Description
              Text(
                'Detailed Description *',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                  color: MainColor().textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                style: TextStyle(color: MainColor().textPrimary),
                decoration: appInputDecoration('Detailed Description').copyWith(
                  hintText: 'Provide detailed explanation of why you are appealing this violation...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a detailed description';
                  }
                  if (value.length < 50) {
                    return 'Description must be at least 50 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Guidelines Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Appeal Guidelines',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Appeals must be filed within 30 days of the violation\n'
                      '• Provide clear and factual information\n'
                      '• Supporting documents may be required\n'
                      '• Processing time is typically 5-10 business days',
                      style: TextStyle(
                        fontSize: FontSizes().caption,
                        color: MainColor().textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAppeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColor().primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Submitting...'),
                          ],
                        )
                      : Text(
                          'Submit Appeal',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _submitAppeal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Simulate API call delay
        await Future.delayed(Duration(seconds: 2));

        // TODO: Implement actual appeal submission logic here
        // This would typically involve:
        // 1. Creating an appeal model
        // 2. Sending data to backend API
        // 3. Storing in Firestore
        // 4. Sending confirmation email

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Appeal Submitted'),
                  ],
                ),
                content: Text(
                  'Your appeal has been successfully submitted. You will receive a confirmation email and updates on the status of your appeal.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous page
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Error'),
                  ],
                ),
                content: Text(
                  'Failed to submit your appeal. Please check your internet connection and try again.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}
