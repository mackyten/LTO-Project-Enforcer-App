import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void showAlert(BuildContext context, String title, String message) {
  HapticFeedback.heavyImpact();
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
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
