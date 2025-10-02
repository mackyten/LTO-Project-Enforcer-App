import 'dart:convert';
import 'dart:io';

import 'package:enforcer_auto_fine/pages/violation/components/header.dart';
import 'package:enforcer_auto_fine/pages/violation/components/navigation.dart';
import 'package:enforcer_auto_fine/pages/violation/components/violation_item.dart';
import 'package:enforcer_auto_fine/pages/violation/handlers.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/pages/violation/models/violations_config.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/components/image_picker/index.dart';
import 'package:enforcer_auto_fine/shared/components/loading_overlay/index.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/components/label.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/index.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/shared/dialogs/alert_dialog.dart';
import 'package:enforcer_auto_fine/utils/shared_preferences.dart';
import 'package:enforcer_auto_fine/utils/local_file_saver.dart';
import 'package:enforcer_auto_fine/utils/file_uploader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../enums/folders.dart';
import 'bloc/violation_bloc.dart';

class ViolationPage extends StatefulWidget {
  final ReportModel? initialData;

  const ViolationPage({super.key, this.initialData});

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
  final uuid = const Uuid().v4();

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

  //Local State
  bool isSaving = false;

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

    if (widget.initialData != null) {
      _fullnameController.text = widget.initialData?.fullname ?? "";
      _addressController.text = widget.initialData?.address ?? "";
      _phoneController.text = widget.initialData?.phoneNumber ?? "";
      _licenseController.text = widget.initialData?.licenseNumber ?? "";
      _plateController.text = widget.initialData?.plateNumber ?? "";

      if (widget.initialData?.licensePhoto != null) {
        licensePhoto = File(widget.initialData!.licensePhoto);
      }
      if (widget.initialData?.platePhoto != null) {
        platePhoto = File(widget.initialData!.platePhoto);
      }
      if (widget.initialData?.evidencePhoto != null) {
        evidencePhoto = File(widget.initialData!.evidencePhoto);
      }

      if (widget.initialData?.violations != null) {
        for (final violationModel in widget.initialData!.violations) {
          // Find the corresponding violation key from the config
          final violationKey = ViolationsConfig.definitions.entries
              .firstWhere(
                (entry) => entry.value.displayName == violationModel.violationName,
                orElse: () => const MapEntry('other', ViolationDefinition(
                  name: 'other',
                  displayName: 'Other Violation',
                  defaultPrice: 1000.0,
                )),
              )
              .key;
          
          context.read<ViolationBloc>().add(
            UpdateViolationEvent(
              key: violationKey,
              value: true, // Set to true since this violation exists in the initial data
            ),
          );
        }
      }
    }
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
        // Validate form fields first
        bool formValid = step2Key.currentState?.validate() ?? false;
        if (!formValid) return false;
        
        // Check if plate photo is uploaded (required)
        if (platePhoto == null) {
          showAlert(context, 'Required', 'Please upload plate photo.');
          return false;
        }
        return true;
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

  Future<String?> submitForm(BuildContext context) async {
    String? trackingNumber;
    setState(() {
      isSaving = true;
    });
    final homeBlocState = context.read<ViolationBloc>().state;
    if (homeBlocState is! HomeLoaded) {
      showAlert(
        context,
        'Error',
        'Home data not loaded. Please try again later.',
      );
      setState(() {
        isSaving = false;
      });
      return null;
    }
    bool isValid = _validateCurrentStep(context);
    if (isValid) {
      HapticFeedback.mediumImpact();
      var licenseUrl = "";
      var plateUrl = "";
      var evidenceUrl = "";
      if (licensePhoto != null) {
        licenseUrl = await CloudinaryService.uploadPhoto(licensePhoto!);
      }
      if (platePhoto != null) {
        plateUrl = await CloudinaryService.uploadPhoto(platePhoto!);
      }
      if (evidencePhoto != null) {
        evidenceUrl = await CloudinaryService.uploadPhoto(evidencePhoto!);
      }

      final data = ReportModel(
        fullname: _fullnameController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        licensePhoto: licenseUrl,
        plateNumber: _plateController.text.trim(),
        platePhoto: plateUrl,
        evidencePhoto: evidenceUrl,
        violations: ViolationsConfig.fromSelectedViolations(homeBlocState.violations),
      );

      trackingNumber = await handleSave(data);
      if (trackingNumber == null) {
        showAlert(context, 'Error', 'Failed to save report. Please try again.');
        setState(() {
          isSaving = false;
        });
        return null;
      }

      if (widget.initialData != null && widget.initialData?.draftId != null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final draftKey = 'draft_${currentUser.uid}_${widget.initialData!.draftId!}';
          deletePreference(draftKey);
        }
      }

      setState(() {
        isSaving = false;
      });
    }

    setState(() {
      isSaving = false;
    });
    return trackingNumber;
  }

  Future<void> navigateBackToHome() async {
    final homeBlocState = context.read<ViolationBloc>().state;
    final uuid = const Uuid().v4(); // Generate a UUID for the new draft

    var licenseUrl = "";
    var plateUrl = "";
    var evidenceUrl = "";
    if (licensePhoto != null &&
        licensePhoto?.path != null &&
        licensePhoto?.path != '') {
      licenseUrl = await saveImageToLocalStorage(
        licensePhoto!,
        "license-$uuid",
      );
    }
    if (platePhoto != null &&
        platePhoto?.path != '' &&
        platePhoto?.path != null) {
      plateUrl = await saveImageToLocalStorage(platePhoto!, "plate-$uuid");
    }
    if (evidencePhoto != null &&
        evidencePhoto?.path != '' &&
        evidencePhoto?.path != null) {
      evidenceUrl = await saveImageToLocalStorage(
        evidencePhoto!,
        "evidence-$uuid",
      );
    }

    if (homeBlocState is HomeLoaded) {
      // Instantiate the ReportModel with the createdAt timestamp
      final report = ReportModel(
        fullname: _fullnameController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        licensePhoto: licenseUrl,
        plateNumber: _plateController.text.trim(),
        platePhoto: plateUrl,
        evidencePhoto: evidenceUrl,
        draftId: uuid,
        violations: ViolationsConfig.fromSelectedViolations(homeBlocState.violations),
        createdAt: DateTime.now(), // Add the creation timestamp here
      );

      final hasData =
          report.fullname.trim().isNotEmpty ||
          report.address.trim().isNotEmpty ||
          report.phoneNumber.trim().isNotEmpty ||
          report.licenseNumber.trim().isNotEmpty ||
          (report.licensePhoto.trim().isNotEmpty) ||
          (report.platePhoto.trim().isNotEmpty) ||
          (report.evidencePhoto.trim().isNotEmpty) ||
          report.violations.isNotEmpty;

      if (hasData) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          print('No authenticated user found, cannot save draft');
          return;
        }
        
        final userUUID = currentUser.uid;
        
        if (widget.initialData != null) {
          deletePreference("draft_${userUUID}_${widget.initialData!.draftId}");
        }
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        final draftKeys = allKeys
            .where((key) => key.startsWith('draft_${userUUID}_'))
            .toList();

        const int maxDrafts = 30;

        // Remove the earliest draft if the limit is exceeded
        if (draftKeys.length >= maxDrafts) {
          // 1. Retrieve all existing drafts for this user
          final List<ReportModel> allDrafts = [];
          for (var key in draftKeys) {
            final reportJsonString = prefs.getString(key);
            if (reportJsonString != null) {
              try {
                final reportMap =
                    jsonDecode(reportJsonString) as Map<String, dynamic>;
                allDrafts.add(ReportModel.fromJson(reportMap));
              } catch (e) {
                print('Error loading draft $key: $e');
                // Remove corrupted draft
                await prefs.remove(key);
              }
            }
          }

          // 2. Sort the drafts by their createdAt attribute
          allDrafts.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

          if (allDrafts.isNotEmpty) {
            final earliestDraft = allDrafts.first;
            final earliestDraftJson = jsonEncode(earliestDraft.toJson());

            // 3. Find the key of the earliest draft and delete it
            final earliestDraftKey = draftKeys.firstWhere(
              (key) => prefs.getString(key) == earliestDraftJson,
              orElse: () => '',
            );

            if (earliestDraftKey.isNotEmpty) {
              await prefs.remove(earliestDraftKey);
              print('Draft limit exceeded. Removed earliest draft.');
            }
          }
        }

        // Save the new draft with user identifier
        final newDraftKey = 'draft_${userUUID}_$uuid';
        final reportJson = jsonEncode(report.toJson());
        await prefs.setString(newDraftKey, reportJson);
        print('Report draft saved with key: $newDraftKey');
      }
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (Route<dynamic> route) => false,
    );
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
      body: Stack(
        children: [
          Container(
            decoration: appBg,
            child: SafeArea(
              child: Column(
                children: [
                  Header(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    previousStep: previousStep,
                    progressAnimation: progressAnimation,
                    backHome: navigateBackToHome,
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
                    submitForm: () => submitForm(context).then(
                      (trackingNumber) => {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: MainColor().success,
                                  size: 60,
                                ),
                                Text('Report submitted successfully!'),
                              ],
                            ),
                            content: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Divider(),
                                  Text(
                                    "Tracking Number",
                                    style: TextStyle(
                                      fontSize: FontSizes().caption,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    trackingNumber ?? "",
                                    style: TextStyle(
                                      fontSize: FontSizes().h3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.copy),
                                    label: Text("Copy to Clipboard"),
                                    onPressed: () {
                                      // Copy the tracking number to the clipboard
                                      if (trackingNumber != null) {
                                        Clipboard.setData(
                                          ClipboardData(text: trackingNumber),
                                        );

                                        // Optional: Show a snackbar or toast to confirm the copy action
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tracking number copied!',
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () {
                                  _resetForm();
                                  if (mounted) Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      },
                    ),
                    nextStep: () => nextStep(context),
                  ),
                ],
              ),
            ),
          ),

          if (isSaving) LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: step1Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Violator\'s Information',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Form Fields
            AppTextField(
              controller: _fullnameController,
              label: 'Full Name',
              placeholder: 'Enter full name',
              required: true,
            ),
            SizedBox(height: 20),
            AppTextField(
              controller: _addressController,
              label: 'Complete Address',
              placeholder: 'Street, City, State, ZIP Code',
              required: true,
              maxLines: 3,
            ),
            SizedBox(height: 20),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              placeholder: '(123) 456-7890',
              required: true,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Info Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ensure all information is accurate as it will be used for official documentation.',
                      style: TextStyle(
                        fontSize: FontSizes().caption,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'License & Vehicle Information',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // License Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Driver\'s License',
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: _licenseController,
                    label: 'License Number',
                    placeholder: 'Enter license number',
                    required: false,
                  ),
                  SizedBox(height: 16),
                  AppTextFieldLabel(label: "License Photo", required: false),
                  SizedBox(height: 8),
                  AppImagePicker(
                    image: licensePhoto,
                    onTap: () => _pickImage(StorageFolders.licensePhotos),
                    icon: '📷',
                    text: 'Tap to upload license photo',
                    subtext: 'Clear photo of the driver\'s license',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Vehicle Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Vehicle Information',
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: _plateController,
                    label: 'Plate Number',
                    placeholder: 'Enter plate number',
                    required: true,
                  ),
                  SizedBox(height: 16),
                  AppTextFieldLabel(label: "Plate Photo", required: true),
                  SizedBox(height: 8),
                  AppImagePicker(
                    image: platePhoto,
                    onTap: () => _pickImage(StorageFolders.platePhotos),
                    icon: '📷',
                    text: 'Tap to upload plate photo',
                    subtext: 'Clear photo of the vehicle plate',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Info Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.camera_alt, color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Take clear, readable photos for accurate identification and processing.',
                      style: TextStyle(
                        fontSize: FontSizes().caption,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Traffic Violations',
                  style: TextStyle(
                    fontSize: FontSizes().body,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Violations Grid
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextFieldLabel(label: "Select all that apply:", required: true),
                SizedBox(height: 16),
                ViolationItem(label: '🚗 Speeding', item: 'speeding'),
                SizedBox(height: 12),
                ViolationItem(label: '🚫 Illegal Parking', item: 'illegal-parking'),
                SizedBox(height: 12),
                ViolationItem(label: '🚦 Running Traffic Light', item: 'traffic-light'),
                SizedBox(height: 12),
                ViolationItem(label: '⚠️ Reckless Driving', item: 'reckless-driving'),
                SizedBox(height: 12),
                ViolationItem(label: '📱 Phone Use While Driving', item: 'phone-use'),
                SizedBox(height: 12),
                ViolationItem(label: '🔒 No Seatbelt', item: 'no-seatbelt'),
                SizedBox(height: 12),
                _buildViolationCard('�', 'Other Violation', 'other', Colors.grey),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Info Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select at least one violation. Multiple violations may apply to a single incident.',
                    style: TextStyle(
                      fontSize: FontSizes().caption,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationCard(String emoji, String title, String item, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ViolationItem(
        label: '$emoji $title',
        item: item,
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Evidence Documentation',
                  style: TextStyle(
                    fontSize: FontSizes().body,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Evidence Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_camera, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Photo Evidence',
                      style: TextStyle(
                        fontSize: FontSizes().body,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: FontSizes().body,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                AppImagePicker(
                  image: evidencePhoto,
                  onTap: () => _pickImage(StorageFolders.evidencePhotos),
                  icon: '📸',
                  text: 'Tap to capture evidence photo',
                  subtext: 'Clear photo showing the violation in progress',
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Guidelines Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Photo Guidelines',
                      style: TextStyle(
                        fontSize: FontSizes().body,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Ensure the photo clearly shows the violation\n'
                  '• Include vehicle and license plate if possible\n'
                  '• Take photo from a safe distance\n'
                  '• Avoid blurry or dark images',
                  style: TextStyle(
                    fontSize: FontSizes().caption,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Confirmation Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  'Report Confirmation',
                  style: TextStyle(
                    fontSize: FontSizes().body,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'By submitting this report, you confirm that all information provided is accurate and truthful. Your report will be reviewed by the appropriate authorities.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: FontSizes().caption,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
