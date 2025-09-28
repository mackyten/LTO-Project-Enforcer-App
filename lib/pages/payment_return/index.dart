import 'package:flutter/material.dart';
import '../../utils/deep_link_handler.dart';

class PaymentReturnPage extends StatelessWidget {
  const PaymentReturnPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically handle the payment return when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkHandler.handlePaymentReturn(context);
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Processing payment result...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
