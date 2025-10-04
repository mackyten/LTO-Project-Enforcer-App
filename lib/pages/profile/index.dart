import 'dart:io';
import 'package:enforcer_auto_fine/pages/auth/handlers.dart';
import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/profile/handlers.dart';
import 'package:enforcer_auto_fine/shared/api/enforcer_id_type.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/components/app_bar/index.dart';
import 'package:enforcer_auto_fine/shared/components/loading_overlay/index.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/shared/dialogs/alert_dialog.dart';
import 'package:enforcer_auto_fine/shared/models/driver_model.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_id_type_model.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/shared/models/user_model.dart';
import 'package:enforcer_auto_fine/utils/input_formatters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentUser = FirebaseAuth.instance.currentUser;

  bool isEditMode = false;
  bool isSaving = false;
  bool obscureReauthPassword = false;
  bool obscureCurrentPassword = false;
  bool obscureNewPassword = false;
  bool obscureConfirmPassword = false;

  // Add scroll controller for FAB animation
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;

  // Track changes for unsaved warning
  bool _hasUnsavedChanges = false;
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalMobileNumber;
  String? _originalSelectedIdType;
  File? _originalBadgePhoto;

  final _emailController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Driver-specific controllers
  final _plateNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  final _reauthPasswordController = TextEditingController();
  String? _selectedIdType;
  File? badgePhoto;
  File? userProfilePic;

  // Original values for driver-specific fields
  String? _originalPlateNumber;
  String? _originalLicenseNumber;

  final ImagePicker _picker = ImagePicker();

  // Cache the future to prevent rebuilding
  late Future<List<EnforcerIdTypeModel>> _idTypesFuture;

  final snackBar = SnackBar(
    content: const Text('Saved Successfully!'),
    backgroundColor: MainColor().success,
  );

  @override
  void initState() {
    super.initState();

    // Initialize the cached future for ID types
    _idTypesFuture = getEnforcerIdTypes();

    // Add scroll listener for FAB animation
    _scrollController.addListener(() {
      final bool isExtended = _scrollController.offset < 50;
      if (isExtended != _isFabExtended) {
        setState(() {
          _isFabExtended = isExtended;
        });
      }
    }); // Add listeners to text controllers to track changes
    _firstNameController.addListener(_checkForChanges);
    _lastNameController.addListener(_checkForChanges);
    _mobileNumberController.addListener(_checkForChanges);
    _plateNumberController.addListener(_checkForChanges);
    _licenseNumberController.addListener(_checkForChanges);

    // Dispatch the event to start fetching data
    context.read<HomeBloc>().add(FetchHomeData());
    final homeBlocState = context.read<HomeBloc>().state;
    if (homeBlocState is HomeLoaded) {
      var user;
      if (homeBlocState.isDriver) {
        user = homeBlocState.driverData!;
      } else {
        user = homeBlocState.enforcerData;
      }
      _emailController.text = user.email;
      _lastNameController.text = user.lastName;
      _firstNameController.text = user.firstName;
      // Initialize mobile number with +63 prefix if empty, otherwise use existing value
      String mobileNumber = user.mobileNumber ?? "";
      if (mobileNumber.isEmpty) {
        _mobileNumberController.text = "+63";
      } else if (!mobileNumber.startsWith("+63")) {
        // If the existing number doesn't have +63, add it (assuming it's a Philippine number without prefix)
        _mobileNumberController.text = "+63$mobileNumber";
      } else {
        _mobileNumberController.text = mobileNumber;
      }

      // Initialize driver-specific fields if user is a driver
      if (homeBlocState.isDriver && user is DriverModel) {
        _plateNumberController.text = user.plateNumber ?? "";
        _licenseNumberController.text = user.driverLicenseNumber ?? "";
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    // Remove listeners before disposing controllers
    _firstNameController.removeListener(_checkForChanges);
    _lastNameController.removeListener(_checkForChanges);
    _mobileNumberController.removeListener(_checkForChanges);
    _plateNumberController.removeListener(_checkForChanges);
    _licenseNumberController.removeListener(_checkForChanges);

    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _mobileNumberController.dispose();
    _plateNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _setSaving() {
    setState(() {
      isSaving = !isSaving;
    });
  }

  void _saveOriginalValues() {
    _originalFirstName = _firstNameController.text;
    _originalLastName = _lastNameController.text;
    _originalMobileNumber = _mobileNumberController.text;
    _originalSelectedIdType = _selectedIdType;
    _originalBadgePhoto = badgePhoto;
    _originalPlateNumber = _plateNumberController.text;
    _originalLicenseNumber = _licenseNumberController.text;
  }

  void _checkForChanges() {
    bool hasChanges =
        _firstNameController.text != (_originalFirstName ?? '') ||
        _lastNameController.text != (_originalLastName ?? '') ||
        _mobileNumberController.text != (_originalMobileNumber ?? '') ||
        _selectedIdType != _originalSelectedIdType ||
        badgePhoto != _originalBadgePhoto ||
        _plateNumberController.text != (_originalPlateNumber ?? '') ||
        _licenseNumberController.text != (_originalLicenseNumber ?? '');

    if (_hasUnsavedChanges != hasChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  void _refreshIdTypes() {
    setState(() {
      _idTypesFuture = getEnforcerIdTypes();
    });
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: MainColor().secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Unsaved Changes',
                      style: TextStyle(
                        color: MainColor().textPrimary,
                        fontSize: FontSizes().h3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'You have unsaved changes. Are you sure you want to leave without saving?',
                style: TextStyle(
                  color: MainColor().textPrimary.withOpacity(0.8),
                  fontSize: FontSizes().body,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: MainColor().textPrimary.withOpacity(0.7),
                  ),
                  child: Text('Stay'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Leave'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _handleCancel() async {
    if (_hasUnsavedChanges) {
      bool shouldLeave = await _showUnsavedChangesDialog();
      if (shouldLeave) {
        // Reset to original values
        _firstNameController.text = _originalFirstName ?? '';
        _lastNameController.text = _originalLastName ?? '';
        _mobileNumberController.text = _originalMobileNumber ?? '';
        _selectedIdType = _originalSelectedIdType;
        badgePhoto = _originalBadgePhoto;
        _plateNumberController.text = _originalPlateNumber ?? '';
        _licenseNumberController.text = _originalLicenseNumber ?? '';

        setState(() {
          isEditMode = false;
          _hasUnsavedChanges = false;
        });
      }
    } else {
      setState(() {
        isEditMode = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (isEditMode && _hasUnsavedChanges) {
      bool shouldLeave = await _showUnsavedChangesDialog();
      if (shouldLeave) {
        // Reset to original values
        _firstNameController.text = _originalFirstName ?? '';
        _lastNameController.text = _originalLastName ?? '';
        _mobileNumberController.text = _originalMobileNumber ?? '';
        _selectedIdType = _originalSelectedIdType;
        badgePhoto = _originalBadgePhoto;
        _plateNumberController.text = _originalPlateNumber ?? '';
        _licenseNumberController.text = _originalLicenseNumber ?? '';

        setState(() {
          isEditMode = false;
          _hasUnsavedChanges = false;
        });
      }
      return shouldLeave;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial || state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is HomeLoaded) {
          var user;
          if (state.isDriver) {
            user = state.driverData!;
          } else {
            user = state.enforcerData;
          }

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Stack(
              children: [
                Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: GlassmorphismAppBar(
                    title: Text(isEditMode ? 'Edit Profile' : 'Profile'),
                    leading: isEditMode
                        ? Container(
                            width: 80,
                            child: TextButton(
                              onPressed: _handleCancel,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: MainColor().textPrimary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () => {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (Route<dynamic> route) => false,
                              ),
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                    actions: isEditMode
                        ? [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: MainColor().textPrimary,
                              ),
                              onPressed: () {
                                _updateData(user);
                              },
                              child: Text('Save'),
                            ),
                          ]
                        : [],
                  ),
                  body: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      return Container(
                        decoration: appBg,
                        height: double.infinity,
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(48, 16, 48, 0),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SafeArea(child: SizedBox()),
                              Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8),
                                    child: CircleAvatar(
                                      radius: 80,
                                      backgroundImage: userProfilePic != null
                                          ? FileImage(userProfilePic!)
                                          : (user
                                                    .profilePictureUrl
                                                    ?.isNotEmpty ==
                                                true)
                                          ? NetworkImage(
                                              user.profilePictureUrl!,
                                            )
                                          : null,
                                      child:
                                          (user.profilePictureUrl?.isEmpty ??
                                              true)
                                          ? Icon(Icons.account_circle, size: 50)
                                          : null,
                                    ),
                                  ),
                                  if (isEditMode)
                                    Positioned(
                                      right: 0,
                                      child: FilledButton.icon(
                                        onPressed: () =>
                                            _pickImage('user-photo'),
                                        label: Icon(Icons.camera_alt),
                                        style: FilledButton.styleFrom(
                                          shape: const CircleBorder(),
                                          backgroundColor: Colors
                                              .blue, // Sets the background color of the circle
                                          foregroundColor: Colors
                                              .white, // Sets the color of the icon and label
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              Form(
                                child: Column(
                                  children: [
                                    SizedBox(height: 32),
                                    _buildProfileField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      readOnly: false,
                                    ),
                                    SizedBox(height: 28),
                                    _buildProfileField(
                                      controller: _lastNameController,
                                      label: 'Last Name',
                                      icon: Icons.person_outline,
                                      readOnly: false,
                                    ),
                                    SizedBox(height: 28),
                                    _buildProfileField(
                                      controller: _firstNameController,
                                      label: 'First Name',
                                      icon: Icons.person_outline,
                                      readOnly: false,
                                    ),
                                    SizedBox(height: 28),
                                    _buildProfileField(
                                      controller: _mobileNumberController,
                                      label: 'Mobile Number',
                                      icon: Icons.phone_outlined,
                                      readOnly: false,
                                      inputFormatters: [
                                        PhilippineMobileNumberFormatter(),
                                      ],
                                      keyboardType: TextInputType.phone,
                                    ),

                                    SizedBox(height: 28),

                                    // Driver-specific fields
                                    if (user is DriverModel) ...[
                                      _buildProfileField(
                                        controller: _plateNumberController,
                                        label: 'Plate Number',
                                        icon: Icons.directions_car,
                                        readOnly: false,
                                      ),
                                      SizedBox(height: 28),
                                      _buildProfileField(
                                        controller: _licenseNumberController,
                                        label: 'Driver License Number',
                                        icon: Icons.badge,
                                        readOnly: false,
                                      ),
                                      SizedBox(height: 28),
                                    ],

                                    // Enforcer-specific fields (ID Type and Badge Photo)
                                    if (user is EnforcerModel) ...[
                                      if (!isEditMode) ...[
                                        // View mode: Modern card-style display for ID Type
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.08),
                                                Colors.white.withOpacity(0.04),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.15,
                                              ),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 15,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.badge,
                                                  color: Colors.orange
                                                      .withOpacity(0.8),
                                                  size: 22,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ID / Badge Type',
                                                      style: TextStyle(
                                                        color: MainColor()
                                                            .textPrimary
                                                            .withOpacity(0.7),
                                                        fontSize:
                                                            FontSizes().caption,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      _selectedIdType ??
                                                          "Not selected",
                                                      style: TextStyle(
                                                        color:
                                                            _selectedIdType !=
                                                                null
                                                            ? MainColor()
                                                                  .textPrimary
                                                            : MainColor()
                                                                  .textPrimary
                                                                  .withOpacity(
                                                                    0.4,
                                                                  ),
                                                        fontSize:
                                                            FontSizes().body,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else ...[
                                        // Edit mode: Modern dropdown
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: _buildIdTypeDropdown(
                                            'Select ID / Badge Type',
                                          ),
                                        ),
                                      ],

                                      SizedBox(height: 32),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 20,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: size.width * .60,
                                                child: badgePhoto != null
                                                    ? Image.file(
                                                        badgePhoto!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : (user.badgePhoto !=
                                                              null &&
                                                          user
                                                              .badgePhoto!
                                                              .isNotEmpty)
                                                    ? Image.network(
                                                        user.badgePhoto!,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder:
                                                            (
                                                              context,
                                                              child,
                                                              loadingProgress,
                                                            ) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value:
                                                                      loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              );
                                                            },
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                            0.1,
                                                                          ),
                                                                      Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                            0.05,
                                                                          ),
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .error_outline,
                                                                        size:
                                                                            48,
                                                                        color: MainColor()
                                                                            .textPrimary
                                                                            .withOpacity(
                                                                              0.4,
                                                                            ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        'Failed to load image',
                                                                        style: TextStyle(
                                                                          color: MainColor().textPrimary.withOpacity(
                                                                            0.6,
                                                                          ),
                                                                          fontSize:
                                                                              FontSizes().caption,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                      )
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.grey
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              Colors.grey
                                                                  .withOpacity(
                                                                    0.05,
                                                                  ),
                                                            ],
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                          ),
                                                        ),
                                                        child: !isEditMode
                                                            ? Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            16,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.1,
                                                                            ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .badge_outlined,
                                                                        size:
                                                                            48,
                                                                        color: MainColor()
                                                                            .textPrimary
                                                                            .withOpacity(
                                                                              0.4,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          16,
                                                                    ),
                                                                    Text(
                                                                      'No badge photo',
                                                                      style: TextStyle(
                                                                        color: MainColor()
                                                                            .textPrimary
                                                                            .withOpacity(
                                                                              0.6,
                                                                            ),
                                                                        fontSize:
                                                                            FontSizes().body,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                              ),
                                              if (isEditMode)
                                                GestureDetector(
                                                  onTap: () =>
                                                      _pickImage('badge-photo'),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                          Colors.black
                                                              .withOpacity(0.5),
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                    ),
                                                    width: double.infinity,
                                                    height: size.width * .60,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  16,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .camera_alt_rounded,
                                                              color:
                                                                  Colors.white,
                                                              size: 32,
                                                            ),
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            "Tap to update photo",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  FontSizes()
                                                                      .body,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 32),
                                    ], // End of enforcer-specific fields

                                    // Common password section for both user types
                                    isEditMode
                                        ? SizedBox()
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.withOpacity(0.8),
                                                  Colors.blue.withOpacity(0.6),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
                                                  blurRadius: 15,
                                                  offset: Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap:
                                                    _showChangePasswordBottomSheet,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 16,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                          10,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .lock_outline_rounded,
                                                          color: Colors.white,
                                                          size: 22,
                                                        ),
                                                      ),
                                                      SizedBox(width: 16),
                                                      Expanded(
                                                        child: Text(
                                                          "Update Password",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                FontSizes()
                                                                    .body,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              SafeArea(child: SizedBox()),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  floatingActionButton: !isEditMode
                      ? AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: _isFabExtended
                              ? FloatingActionButton.extended(
                                  onPressed: () {
                                    _saveOriginalValues();
                                    setState(() {
                                      isEditMode = true;
                                    });
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  icon: Icon(Icons.edit_rounded),
                                  label: Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                )
                              : FloatingActionButton(
                                  onPressed: () {
                                    _saveOriginalValues();
                                    setState(() {
                                      isEditMode = true;
                                    });
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  child: Icon(Icons.edit_rounded),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                        )
                      : null,
                ),
                if (isSaving) LoadingOverlay(),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          if (type == "user-photo") {
            userProfilePic = File(image.path);
          } else if (type == "badge-photo") {
            badgePhoto = File(image.path);
          }
        });
        _checkForChanges(); // Check for changes after image update
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      showAlert(context, 'Reqiured', 'Failed to pick image. Please try again.');
    }
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool readOnly,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    if (isEditMode) {
      // Edit mode: Modern text field with subtle styling
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          style: TextStyle(
            color: MainColor().textPrimary,
            fontSize: FontSizes().body,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: MainColor().textPrimary.withOpacity(0.7),
              fontSize: FontSizes().caption,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.blue.withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Container(
              margin: EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                icon,
                color: MainColor().textPrimary.withOpacity(0.6),
                size: 20,
              ),
            ),
          ),
        ),
      );
    } else {
      // View mode: Modern card-style display
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.withOpacity(0.8), size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: MainColor().textPrimary.withOpacity(0.7),
                      fontSize: FontSizes().caption,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    controller.text.isEmpty ? 'Not provided' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? MainColor().textPrimary.withOpacity(0.4)
                          : MainColor().textPrimary,
                      fontSize: FontSizes().body,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildIdTypeDropdown(String label) {
    return FutureBuilder<List<EnforcerIdTypeModel>>(
      future: _idTypesFuture, // Use cached future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.badge,
                  color: MainColor().textPrimary.withOpacity(0.6),
                  size: 20,
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MainColor().textPrimary.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Loading ID types...',
                  style: TextStyle(
                    color: MainColor().textPrimary.withOpacity(0.7),
                    fontSize: FontSizes().caption,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return GestureDetector(
            onTap: _refreshIdTypes,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error loading ID types. Tap to retry.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: FontSizes().caption,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: MainColor().textPrimary.withOpacity(0.6),
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'No ID types available',
                  style: TextStyle(
                    color: MainColor().textPrimary.withOpacity(0.7),
                    fontSize: FontSizes().caption,
                  ),
                ),
              ],
            ),
          );
        } else {
          final idTypes = snapshot.data!;

          // Validate _selectedIdType against available options
          if (_selectedIdType != null &&
              !idTypes.any((type) => type.id == _selectedIdType)) {
            // Reset if selected type is not in the list
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedIdType = null;
                });
              }
            });
          }

          return DropdownButtonFormField<String>(
            key: ValueKey('id_type_dropdown'), // Add key for stability
            isExpanded: true,
            dropdownColor: MainColor().secondary,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: MainColor().textPrimary.withOpacity(0.7),
                fontSize: FontSizes().caption,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.blue.withOpacity(0.5),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.badge,
                  color: MainColor().textPrimary.withOpacity(0.6),
                  size: 20,
                ),
              ),
            ),
            value: _selectedIdType,
            hint: Text(
              'Choose your ID/Badge type',
              style: TextStyle(
                color: MainColor().textPrimary.withOpacity(0.5),
                fontSize: FontSizes().caption,
              ),
            ),
            onChanged: (String? newValue) {
              // Debounce the state change to prevent rapid rebuilds
              Future.microtask(() {
                if (mounted && _selectedIdType != newValue) {
                  setState(() {
                    _selectedIdType = newValue;
                  });
                  _checkForChanges();
                }
              });
            },
            items: idTypes.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item.id,
                child: Text(
                  item.type,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: MainColor().textPrimary,
                    fontSize: FontSizes().body,
                  ),
                ),
              );
            }).toList(),
            validator: (value) {
              if (isEditMode && (value == null || value.isEmpty)) {
                return 'Please select an ID/Badge type';
              }
              return null;
            },
          );
        }
      },
    );
  }

  _updateData<T extends UserModel>(T user) async {
    if (currentUser != null && currentUser!.email != _emailController.text) {
      // Intercept the save process and request re-authentication.
      bool? reauthenticated = await onPasswordVerify();
      if (reauthenticated == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email update cancelled. Reauthentication failed."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Exit the function if reauthentication fails.
      }
    }
    _setSaving();

    var updatedUserData = user is EnforcerModel
        ? EnforcerModel(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            mobileNumber: _mobileNumberController.text,
            createdAt: null,
            roles: [],
          )
        : DriverModel(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            mobileNumber: _mobileNumberController.text,
            plateNumber: _plateNumberController.text.isEmpty
                ? null
                : _plateNumberController.text,
            driverLicenseNumber: _licenseNumberController.text.isEmpty
                ? null
                : _licenseNumberController.text,
            createdAt: null,
            roles: [],
          );

    if (badgePhoto != null) {
      updatedUserData.tempBadgePhoto = badgePhoto;
    }
    if (userProfilePic != null) {
      updatedUserData.tempProfilePicture = userProfilePic;
    }

    try {
      await handleSaveData(updatedUserData);
      setState(() {
        isEditMode = false;
        _hasUnsavedChanges = false; // Reset unsaved changes flag
      });
      _setSaving();
      if (mounted) {
        String successMessage = "Profile updated successfully!";

        // Add special message if email was changed
        if (currentUser != null &&
            currentUser!.email != _emailController.text) {
          successMessage +=
              " Your email has been updated in both profile and authentication.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: MainColor().success,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      _setSaving();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<bool?> onPasswordVerify() async {
    String? password = await showModalBottomSheet<String>(
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        // Use StatefulBuilder to manage local state within the modal
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter innerSetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          "For security reasons, we need to confirm it’s really you before updating your email address. Please enter your current password to continue.",
                          style: TextStyle(
                            fontSize: FontSizes().h4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          obscureText:
                              obscureReauthPassword, // This variable is from the parent state
                          canRequestFocus: true,
                          controller: _reauthPasswordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureReauthPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                // Call the local setState from StatefulBuilder
                                innerSetState(() {
                                  obscureReauthPassword =
                                      !obscureReauthPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pop(_reauthPasswordController.text);
                                },
                                child: const Text('Continue'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (password != null && password.isNotEmpty) {
      final bool reauthenticated = await reauthenticateUser(
        currentUser!.email!,
        password,
      );
      return reauthenticated;
    }

    return false;
  }

  _showChangePasswordBottomSheet() async {
    showModalBottomSheet(
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        String error = '';
        final isValid =
            (_newPasswordController.text == _confirmPasswordController.text) &&
            _currentPasswordController.text.isNotEmpty &&
            _newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty;
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter innerSetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: FontSizes().h4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          autocorrect: false,
                          autofillHints: [],
                          obscureText:
                              obscureCurrentPassword, // This variable is from the parent state
                          canRequestFocus: true,
                          controller: _currentPasswordController,
                          decoration: InputDecoration(
                            label: Text("Current Password"),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                // Call the local setState from StatefulBuilder
                                innerSetState(() {
                                  obscureCurrentPassword =
                                      !obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          autocorrect: false,
                          autofillHints: [],
                          obscureText:
                              obscureNewPassword, // This variable is from the parent state
                          canRequestFocus: true,
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            label: Text("New Password"),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                // Call the local setState from StatefulBuilder
                                innerSetState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        TextField(
                          autocorrect: false,
                          autofillHints: [],
                          obscureText:
                              obscureConfirmPassword, // This variable is from the parent state
                          canRequestFocus: true,
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            label: Text("Confirm Password"),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                // Call the local setState from StatefulBuilder
                                innerSetState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        if (error.isNotEmpty) SizedBox(height: 16),

                        if (error.isNotEmpty)
                          Text(
                            error,
                            style: TextStyle(color: MainColor().error),
                          ),

                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isValid
                                    ? () async {
                                        var result =
                                            await reauthenticateAndChangePassword(
                                              _currentPasswordController.text,
                                              _newPasswordController.text,
                                            );
                                        if (result.success && mounted) {
                                          innerSetState(() {
                                            error = "";
                                          });
                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Password successfully updated.",
                                              ),
                                              backgroundColor:
                                                  MainColor().success,
                                            ),
                                          );
                                          return;
                                        }

                                        innerSetState(() {
                                          error = result.message ?? "";
                                        });
                                      }
                                    : null,
                                child: const Text('Continue'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }
}
