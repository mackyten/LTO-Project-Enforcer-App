import 'dart:io';

import 'package:enforcer_auto_fine/pages/home/components/header.dart';
import 'package:enforcer_auto_fine/pages/home/components/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> progressAnimation;

  int currentStep = 0;
  final int totalSteps = 4;

  // Form controllers
  final _fullnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();

  // Form validation keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // Violation checkboxes
  Map<String, bool> violations = {
    'speeding': false,
    'illegal-parking': false,
    'traffic-light': false,
    'reckless-driving': false,
    'phone-use': false,
    'no-seatbelt': false,
    'other': false,
  };

  // Image files
  File? licensePhoto;
  File? evidencePhoto;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    progressAnimation = Tween<double>(begin: 0.25, end: 0.25).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _fullnameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (_validateCurrentStep()) {
      if (currentStep < totalSteps - 1) {
        setState(() {
          currentStep++;
        });
        _updateProgress();
        _pageController.nextPage(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        HapticFeedback.lightImpact();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _updateProgress();
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _updateProgress() {
    double progress = (currentStep + 1) / totalSteps;
    progressAnimation =
        Tween<double>(begin: progressAnimation.value, end: progress).animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );
    _progressController.forward(from: 0);
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return _step1Key.currentState?.validate() ?? false;
      case 1:
        return _step2Key.currentState?.validate() ?? false;
      case 2:
        if (!violations.values.any((selected) => selected)) {
          _showAlert('Please select at least one violation.');
          return false;
        }
        return true;
      case 3:
        if (evidencePhoto == null) {
          _showAlert('Please upload evidence photo.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showAlert(String message) {
    HapticFeedback.heavyImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Required'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(bool isLicense) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          if (isLicense) {
            licensePhoto = File(image.path);
          } else {
            evidencePhoto = File(image.path);
          }
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showAlert('Failed to pick image. Please try again.');
    }
  }

  void submitForm() {
    if (_validateCurrentStep()) {
      HapticFeedback.mediumImpact();

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('✅ Success'),
          content: Text(
            'Report submitted successfully!\n\nThank you for helping keep our community safe.',
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      currentStep = 0;
      _fullnameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _licenseController.clear();
      violations.updateAll((key, value) => false);
      licensePhoto = null;
      evidencePhoto = null;
    });
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _updateProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Header(
                currentStep: currentStep,
                totalSteps: totalSteps,
                previousStep: previousStep,
                progressAnimation: progressAnimation,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),
              Navigation(
                currentStep: currentStep,
                totalSteps: totalSteps,
                previousStep: previousStep,
                submitForm: submitForm,
                nextStep: nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Violator\'s Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 30),
            _buildTextField(
              controller: _fullnameController,
              label: 'Full Name',
              placeholder: 'Enter full name',
              required: true,
            ),
            SizedBox(height: 25),
            _buildTextField(
              controller: _addressController,
              label: 'Complete Address',
              placeholder: 'Street, City, State, ZIP Code',
              required: true,
              maxLines: 4,
            ),
            SizedBox(height: 25),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              placeholder: '(123) 456-7890',
              required: true,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'License Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 30),
            _buildTextField(
              controller: _licenseController,
              label: 'License Number',
              placeholder: 'Enter license number',
              required: true,
            ),
            SizedBox(height: 25),
            _buildLabel('License Photo'),
            SizedBox(height: 10),
            _buildImagePicker(
              image: licensePhoto,
              onTap: () => _pickImage(true),
              icon: '📷',
              text: 'Tap to upload license photo',
              subtext: 'JPG, PNG up to 10MB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rules Violated',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 30),
          _buildLabel('Select all that apply:', required: true),
          SizedBox(height: 15),
          _buildViolationItem('🚗 Speeding', 'speeding'),
          _buildViolationItem('🚫 Illegal Parking', 'illegal-parking'),
          _buildViolationItem('🚦 Running Traffic Light', 'traffic-light'),
          _buildViolationItem('⚠️ Reckless Driving', 'reckless-driving'),
          _buildViolationItem('📱 Phone Use While Driving', 'phone-use'),
          _buildViolationItem('🔒 No Seatbelt', 'no-seatbelt'),
          _buildViolationItem('📝 Other', 'other'),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 30),
          _buildLabel('Photo Evidence', required: true),
          SizedBox(height: 10),
          _buildImagePicker(
            image: evidencePhoto,
            onTap: () => _pickImage(false),
            icon: '📸',
            text: 'Tap to upload proof photo',
            subtext: 'Clear photo of the violation',
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Text(
              '🔒 By submitting this report, you confirm that all information provided is accurate and truthful. Your report will be reviewed by the appropriate authorities.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white, fontSize: 17),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFFFF3B30), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFFF3B30)),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildViolationItem(String text, String key) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            violations[key] = !violations[key]!;
          });
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: violations[key]!
                ? Color(0xFF007AFF).withOpacity(0.15)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: violations[key]!
                  ? Color(0xFF007AFF)
                  : Colors.white.withOpacity(0.12),
              width: violations[key]! ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: violations[key]!
                      ? Color(0xFF007AFF)
                      : Colors.transparent,
                  border: Border.all(
                    color: violations[key]!
                        ? Color(0xFF007AFF)
                        : Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: violations[key]!
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required File? image,
    required VoidCallback onTap,
    required String icon,
    required String text,
    required String subtext,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: image != null
              ? Color(0xFF30D158).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null
                ? Color(0xFF30D158)
                : Colors.white.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (image == null) ...[
              Text(icon, style: TextStyle(fontSize: 40)),
              SizedBox(height: 12),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtext,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ] else ...[
              Icon(Icons.check_circle, color: Color(0xFF30D158), size: 40),
              SizedBox(height: 12),
              Text(
                '✅ Image selected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Tap to change',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
