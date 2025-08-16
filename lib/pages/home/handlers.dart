import 'dart:io';

import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/shared/dialogs/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool handleValidateCurrentStep(
  BuildContext context,
  int currentStep,
  GlobalKey<FormState> step1Key,
  GlobalKey<FormState> step2Key,
  File? evidencePhoto,
) {
  final homeBlocState = context.read<HomeBloc>().state;

  switch (currentStep) {
    case 0:
      return step1Key.currentState?.validate() ?? false;
    case 1:
      return step2Key.currentState?.validate() ?? false;
    case 2:
      // Check the violations from the BLoC state
      if (homeBlocState is HomeLoaded) {
        if (!homeBlocState.violations.values.any((selected) => selected)) {
          showAlert(
            context,
            'Required',
            'Please select at least one violation.',
          );
          return false;
        }
        return true;
      }
      return false; // Return false if the state isn't HomeLoaded
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
