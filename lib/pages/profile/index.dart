import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/shared/api/enforcer_id_type.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/components/app_bar/index.dart';
import 'package:enforcer_auto_fine/shared/components/textfield/app_input_border.dart';
import 'package:enforcer_auto_fine/shared/decorations/app_bg.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_id_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isEditMode = false;
  void initState() {
    super.initState();
    // Dispatch the event to start fetching data
    context.read<HomeBloc>().add(FetchHomeData());
  }

  void _setEdit() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  String? _selectedIdType;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
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
            onPressed: _setEdit,
            child: Text(isEditMode ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is HomeLoaded) {
            var user = state.enforcerData;
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
                            backgroundImage: user.profilePictureUrl.isNotEmpty
                                ? NetworkImage(user.profilePictureUrl)
                                : null,
                            child: user.profilePictureUrl.isEmpty
                                ? Icon(Icons.account_circle, size: 50)
                                : null,
                          ),
                        ),
                        if (isEditMode)
                          Positioned(
                            right: 0,
                            child: FilledButton.icon(
                              onPressed: () {},
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
                            initialValue: user.email,
                            label: 'Email',
                          ),
                          SizedBox(height: 24),
                          _buildTextField(
                            initialValue: user.lastName,
                            label: 'Lastname',
                          ),
                          SizedBox(height: 24),
                          _buildTextField(
                            initialValue: user.firstName,
                            label: 'Firstname',
                          ),

                          SizedBox(height: 24),
                          _buildTextField(
                            initialValue: user.mobileNumber,
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
                            borderRadius: BorderRadiusGeometry.circular(10),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: size.width * .60,

                                  child:
                                      (user.badgePhoto == null ||
                                          user.badgePhoto!.isEmpty)
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'No photo',
                                              style: TextStyle(
                                                color: isEditMode
                                                    ? Colors.transparent
                                                    : MainColor().textPrimary,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                          user.badgePhoto!,

                                          fit: BoxFit.cover,

                                          loadingBuilder:
                                              (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                        ),
                                ),
                                if (isEditMode)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                    ),
                                    width: double.infinity,
                                    height: size.width * .60,
                                    child: Center(
                                      child: Text(
                                        "Tap to update photo",
                                        style: TextStyle(
                                          color: MainColor().textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  _buildTextField({String? initialValue, String? label}) {
    return TextFormField(
      readOnly: !isEditMode,
      initialValue: initialValue,
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
            _selectedIdType = idTypes.first.id;
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
                  style: TextStyle(
                    color: MainColor().textPrimary
                  ),
                ),
              );
            }).toList(),
            style: TextStyle(color: MainColor().textPrimary),
          );
        }
      },
    );
  }
}
