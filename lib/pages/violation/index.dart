import 'dart:convert';
import 'dart:io';

import 'package:enforcer_auto_fine/pages/violation/components/header.dart';
import 'package:enforcer_auto_fine/pages/violation/components/navigation.dart';
import 'package:enforcer_auto_fine/pages/violation/components/violation_item.dart';
import 'package:enforcer_auto_fine/pages/violation/handlers.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/components/image_picker/index.dart';
import 'package:enforcer_auto_fine/shared/components/loading_overlay/index.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/components/label.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/index.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/shared/dialogs/alert_dialog.dart';
import 'package:enforcer_auto_fine/utils/shared_preferences.dart';
import 'package:enforcer_auto_fine/utils/local_file_saver.dart';
import 'package:enforcer_auto_fine/utils/tracking_no_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../enums/folders.dart';
import '../../utils/file_uploader.dart';
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
        widget.initialData!.violations.forEach(
          (item) => context.read<ViolationBloc>().add(
            UpdateViolationEvent(
              key: item,
              value: widget.initialData!.violations.contains(item),
            ),
          ),
        );
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
      return;
    }
    bool isValid = _validateCurrentStep(context);
    if (isValid) {
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
        setState(() {
          isSaving = false;
        });
        return;
      }

      if (widget.initialData != null && widget.initialData?.draftId != null) {
        final draftKey = 'draft_${widget.initialData!.draftId!}';
        deletePreference(draftKey);
      }

      setState(() {
        isSaving = false;
      });
    }

    setState(() {
      isSaving = false;
    });
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
        fullname: _fullnameController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        licenseNumber: _licenseController.text,
        licensePhoto: licenseUrl,
        plateNumber: _plateController.text,
        platePhoto: plateUrl,
        evidencePhoto: evidenceUrl,
        draftId: uuid,
        violations: homeBlocState.violations.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        createdAt: DateTime.now(), // Add the creation timestamp here
      );

      final hasData =
          report.fullname.isNotEmpty ||
          report.address.isNotEmpty ||
          report.phoneNumber.isNotEmpty ||
          report.licenseNumber.isNotEmpty ||
          (report.licensePhoto.isNotEmpty) ||
          (report.platePhoto.isNotEmpty) ||
          (report.evidencePhoto.isNotEmpty) ||
          report.violations.isNotEmpty;

      if (hasData) {
        if (widget.initialData != null) {
          deletePreference("draft_${widget.initialData!.draftId}");
        }
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        final draftKeys = allKeys
            .where((key) => key.startsWith('draft_'))
            .toList();

        const int maxDrafts = 30;

        // Remove the earliest draft if the limit is exceeded
        if (draftKeys.length >= maxDrafts) {
          // 1. Retrieve all existing drafts
          final List<ReportModel> allDrafts = [];
          for (var key in draftKeys) {
            final reportJsonString = prefs.getString(key);
            if (reportJsonString != null) {
              final reportMap =
                  jsonDecode(reportJsonString) as Map<String, dynamic>;
              allDrafts.add(ReportModel.fromJson(reportMap));
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

        // Save the new draft
        final newDraftKey = 'draft_$uuid';
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
                      (e) => {
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
