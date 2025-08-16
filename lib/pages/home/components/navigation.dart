import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback previousStep;
  final VoidCallback submitForm;
  final VoidCallback nextStep;

  const Navigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.previousStep,
    required this.submitForm,
    required this.nextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 16),
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                onPressed: previousStep,
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
          ],
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 16),
              color: Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(14),
              onPressed: currentStep == totalSteps - 1 ? submitForm : nextStep,
              child: Text(
                currentStep == totalSteps - 1 ? 'Submit Report' : 'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
