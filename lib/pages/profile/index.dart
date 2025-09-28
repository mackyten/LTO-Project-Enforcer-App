import 'dart:io';
import 'package:enforcer_auto_fine/pages/auth/handlers.dart';
import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/profile/handlers.dart';
import 'package:enforcer_auto_fine/shared/api/enforcer_id_type.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/components/app_bar/index.dart';
import 'package:enforcer_auto_fine/shared/components/loading_overlay/index.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/app_input_border.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/shared/dialogs/alert_dialog.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_id_type_model.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/shared/models/user_model.dart';
import 'package:enforcer_auto_fine/utils/file_uploader.dart';
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

  final _emailController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _reauthPasswordController = TextEditingController();
  String? _selectedIdType;
  File? badgePhoto;
  File? userProfilePic;

  final ImagePicker _picker = ImagePicker();

  final snackBar = SnackBar(
    content: const Text('Saved Successfully!'),
    backgroundColor: MainColor().success,
  );

  @override
  void initState() {
    super.initState();
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
      _mobileNumberController.text = user.mobileNumber ?? "";
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  void _setEdit() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void _setSaving() {
    setState(() {
      isSaving = !isSaving;
    });
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

          return Stack(
            children: [
              Scaffold(
                extendBodyBehindAppBar: true,
                appBar: GlassmorphismAppBar(
                  title: Text(isEditMode ? 'Edit Profile' : 'Profile'),
                  leading: isEditMode
                      ? null
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
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: MainColor().textPrimary,
                      ),
                      onPressed: () {
                        if (isEditMode) {
                          _updateData(user.uuid);
                        } else {
                          _setEdit();
                        }
                      },
                      child: Text(isEditMode ? 'Save' : 'Edit'),
                    ),
                  ],
                ),
                body: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return Container(
                      decoration: appBg,
                      height: double.infinity,
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: SingleChildScrollView(
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
                                        : (user.profilePictureUrl?.isNotEmpty == true)
                                        ? NetworkImage(user.profilePictureUrl!)
                                        : null,
                                    child: (user.profilePictureUrl?.isEmpty ?? true)
                                        ? Icon(Icons.account_circle, size: 50)
                                        : null,
                                  ),
                                ),
                                if (isEditMode)
                                  Positioned(
                                    right: 0,
                                    child: FilledButton.icon(
                                      onPressed: () => _pickImage('user-photo'),
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
                                  _buildTextField(
                                    readOnly: true,
                                    controller: _emailController,
                                    label: 'Email',
                                  ),
                                  SizedBox(height: 24),
                                  _buildTextField(
                                    readOnly: false,
                                    controller: _lastNameController,
                                    label: 'Lastname',
                                  ),
                                  SizedBox(height: 24),
                                  _buildTextField(
                                    readOnly: false,
                                    controller: _firstNameController,
                                    label: 'Firstname',
                                  ),

                                  SizedBox(height: 24),
                                  _buildTextField(
                                    readOnly: false,
                                    controller: _mobileNumberController,
                                    label: 'Mobile Number',
                                  ),

                                  SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      "ID / Badge Photo",
                                      style: TextStyle(
                                        color: MainColor().textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: FontSizes().h4,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),

                                  SizedBox(height: 24),
                                  _buildIdTypeDropdown('Select Type'),

                                  SizedBox(height: 24),
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      10,
                                    ),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: size.width * .60,
                                          child: badgePhoto != null
                                              ? Image.file(
                                                  badgePhoto!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white12,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'No badge photo',
                                                      style: TextStyle(
                                                        color: isEditMode
                                                            ? Colors.transparent
                                                            : MainColor()
                                                                  .textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        if (isEditMode)
                                          GestureDetector(
                                            onTap: () =>
                                                _pickImage('badge-photo'),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                              ),
                                              width: double.infinity,
                                              height: size.width * .60,
                                              child: Center(
                                                child: Text(
                                                  "Tap to update photo",
                                                  style: TextStyle(
                                                    color:
                                                        MainColor().textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  Card(
                                    color: Colors
                                        .blue, // Change this to your desired color
                                    child: ListTile(
                                      onTap: _showChangePasswordBottomSheet,
                                      textColor: MainColor().textPrimary,
                                      iconColor: MainColor().textPrimary,
                                      leading: Icon(Icons.lock),
                                      title: Text("Update Password"),
                                      trailing: Icon(Icons.arrow_forward_ios),
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
              ),
              if (isSaving) LoadingOverlay(),
            ],
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
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      showAlert(context, 'Reqiured', 'Failed to pick image. Please try again.');
    }
  }

  _buildTextField({
    required TextEditingController controller,
    required bool readOnly,
    String? label,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly ? readOnly : !isEditMode,
      style: TextStyle(color: MainColor().textPrimary),
      decoration: isEditMode
          ? appInputDecoration(label)
          : InputDecoration(
              label: Text(label ?? ''),
              labelStyle: TextStyle(color: MainColor().textPrimary),
              border: UnderlineInputBorder(),
            ),
    );
  }

  _buildIdTypeDropdown(String label) {
    return FutureBuilder<List<EnforcerIdTypeModel>>(
      future: getEnforcerIdTypes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data found.');
        } else {
          final idTypes = snapshot.data!;

          if (_selectedIdType == null && idTypes.isNotEmpty) {
            _selectedIdType = null;
          }

          return DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: MainColor().secondary,
            decoration: isEditMode
                ? appInputDecoration(label)
                : InputDecoration(
                    label: Text(label),
                    labelStyle: TextStyle(color: MainColor().textPrimary),

                    border: UnderlineInputBorder(),
                  ),
            value: _selectedIdType,
            onChanged: isEditMode
                ? (String? newValue) {
                    // Use a ternary operator here
                    setState(() {
                      _selectedIdType = newValue;
                    });
                  }
                : null,
            items: idTypes.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item.id,
                child: Text(
                  softWrap: true,
                  item.type,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: MainColor().textPrimary),
                ),
              );
            }).toList(),
            style: TextStyle(color: MainColor().textPrimary),
          );
        }
      },
    );
  }

  _updateData(String uuid) async {
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
    var updatedUserData = new UserModel(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      uuid: uuid,
      email: _emailController.text,
      mobileNumber: _mobileNumberController.text,
    );

    if (badgePhoto != null) {
      updatedUserData.tempBadgePhoto = await CloudinaryService.uploadPhoto(
        badgePhoto!,
      );
    }
    if (userProfilePic != null) {
      updatedUserData.tempProfilePicture = await CloudinaryService.uploadPhoto(
        userProfilePic!,
      );
    }
    await handleSaveData(updatedUserData);
    _setEdit();
    _setSaving();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
