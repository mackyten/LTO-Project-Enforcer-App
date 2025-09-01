import 'dart:io';

import 'package:enforcer_auto_fine/pages/violation/components/header.dart';
import 'package:enforcer_auto_fine/pages/violation/components/navigation.dart';
import 'package:enforcer_auto_fine/pages/violation/components/violation_item.dart';
import 'package:enforcer_auto_fine/pages/violation/handlers.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/components/image_picker/index.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/components/label.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/index.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/shared/dialogs/alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../enums/folders.dart';
import '../../utils/file_uploader.dart';
import 'bloc/violation_bloc.dart';

class ViolationPage extends StatefulWidget {
  const ViolationPage({super.key});

  @override
  State<ViolationPage> createState() => _ViolationPageState();
}

class _ViolationPageState extends State<ViolationPage>
    with TickerProviderStateMixin {
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
  final _plateController = TextEditingController();

  // Form validation keys
  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();

  // Image files
  File? licensePhoto;
  File? platePhoto;
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

  void nextStep(BuildContext context) {
    if (_validateCurrentStep(context)) {
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

  bool _validateCurrentStep(BuildContext context) {
    final homeBlocState = context.read<ViolationBloc>().state;

    switch (currentStep) {
      case 0:
        return step1Key.currentState?.validate() ?? false;
      case 1:
        return step2Key.currentState?.validate() ?? false;
      case 2:
        if (homeBlocState is HomeLoaded) {
          if (!homeBlocState.violations.values.any((selected) => selected)) {
            showAlert(
              context,
              'Required',
              'Please select at least one violation.',
            );
            return false;
          }
        }
        return true;
      case 3:
        if (evidencePhoto == null) {
          showAlert(context, 'Required', 'Please upload evidence photo.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _pickImage(StorageFolders type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          if (type == StorageFolders.licensePhotos) {
            licensePhoto = File(image.path);
          } else if (type == StorageFolders.evidencePhotos) {
            evidencePhoto = File(image.path);
          } else if (type == StorageFolders.platePhotos) {
            platePhoto = File(image.path);
          } else {
            throw Exception('Invalid folder type');
          }
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      //showAlert(context, 'Reqiured', 'Failed to pick image. Please try again.');
    }
  }

  Future<void> submitForm(BuildContext context) async {
    final homeBlocState = context.read<ViolationBloc>().state;
    if (homeBlocState is! HomeLoaded) {
      showAlert(
        context,
        'Error',
        'Home data not loaded. Please try again later.',
      );
      return;
    }
    if (_validateCurrentStep(context)) {
      HapticFeedback.mediumImpact();
      var licenseUrl = "";
      var plateUrl = "";
      var evidenceUrl = "";
      if (licensePhoto != null) {
        licenseUrl = await uploadPhoto(
          licensePhoto!,
          StorageFolders.licensePhotos,
        );
      }
      if (platePhoto != null) {
        plateUrl = await uploadPhoto(platePhoto!, StorageFolders.platePhotos);
      }
      if (evidencePhoto != null) {
        evidenceUrl = await uploadPhoto(
          evidencePhoto!,
          StorageFolders.evidencePhotos,
        );
      }

      final data = ReportModel(
        fullname: _fullnameController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        licenseNumber: _licenseController.text,
        licensePhoto: licenseUrl,
        plateNumber: _plateController.text,
        platePhoto: plateUrl,
        evidencePhoto: evidenceUrl,
        violations: homeBlocState.violations.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
      );

      var result = await handleSave(data);
      if (!result) {
        showAlert(context, 'Error', 'Failed to save report. Please try again.');
        return;
      }

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
    final homeBlocState = context.read<ViolationBloc>().state;

    setState(() {
      currentStep = 0;
      _fullnameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _licenseController.clear();

      licensePhoto = null;
      evidencePhoto = null;
    });
    if (homeBlocState is HomeLoaded) {
      setState(() {
        homeBlocState.violations.updateAll((key, value) => false);
      });
    }
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
        decoration: appBg,
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
                submitForm: () => submitForm(context),
                nextStep: () => nextStep(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: step1Key,
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
            AppTextField(
              controller: _fullnameController,
              label: 'Full Name',
              placeholder: 'Enter full name',
              required: true,
            ),
            SizedBox(height: 25),
            AppTextField(
              controller: _addressController,
              label: 'Complete Address',
              placeholder: 'Street, City, State, ZIP Code',
              required: true,
              maxLines: 4,
            ),
            SizedBox(height: 25),
            AppTextField(
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
      key: step2Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'License and Plate Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 30),
            AppTextField(
              controller: _licenseController,
              label: 'License Number',
              placeholder: 'Enter license number',
              required: true,
            ),
            SizedBox(height: 25),
            AppTextFieldLabel(label: "License Photo", required: true),
            SizedBox(height: 10),
            AppImagePicker(
              image: licensePhoto,
              onTap: () => _pickImage(StorageFolders.licensePhotos),
              icon: '📷',
              text: 'Tap to upload license photo',
              subtext: 'JPG, PNG up to 10MB',
            ),

            SizedBox(height: 30),
            AppTextField(
              controller: _plateController,
              label: 'plate Number',
              placeholder: 'Enter plate number',
              required: true,
            ),
            SizedBox(height: 25),
            AppTextFieldLabel(label: "Plate Photo", required: true),
            SizedBox(height: 10),
            AppImagePicker(
              image: platePhoto,
              onTap: () => _pickImage(StorageFolders.platePhotos),
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
          AppTextFieldLabel(label: "Select all that apply:", required: true),
          SizedBox(height: 15),
          ViolationItem(label: '🚗 Speeding', item: 'speeding'),
          ViolationItem(label: '🚫 Illegal Parking', item: 'illegal-parking'),
          ViolationItem(
            label: '🚦 Running Traffic Light',
            item: 'traffic-light',
          ),
          ViolationItem(label: '⚠️ Reckless Driving', item: 'reckless-driving'),
          ViolationItem(label: '📱 Phone Use While Driving', item: 'phone-use'),
          ViolationItem(label: '🔒 No Seatbelt', item: 'no-seatbelt'),
          ViolationItem(label: '📝 Other', item: 'other'),
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
          AppTextFieldLabel(label: 'Photo Evidence', required: true),
          SizedBox(height: 10),
          AppImagePicker(
            image: evidencePhoto,
            onTap: () => _pickImage(StorageFolders.evidencePhotos),
            icon: '📸',
            text: 'Tap to upload proof photo',
            subtext: 'Clear photo of the violation',
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03), //.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.03),
                width: 1,
              ),
            ),
            child: Text(
              '🔒 By submitting this report, you confirm that all information provided is accurate and truthful. Your report will be reviewed by the appropriate authorities.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
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
}
