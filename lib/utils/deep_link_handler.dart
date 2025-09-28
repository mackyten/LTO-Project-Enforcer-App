import 'package:flutter/material.dart';

class DeepLinkHandler {
  /// Handle payment return deep link
  static void handlePaymentReturn(BuildContext context, {String? status, String? paymentId}) {
    // Show result based on payment status
    if (status == 'success') {
      _showPaymentSuccess(context, paymentId);
    } else if (status == 'failed') {
      _showPaymentFailure(context);
    } else {
      // Default case - just navigate back
      _showPaymentResult(context);
    }
  }
  
  /// Show general payment result (when status is unknown)
  static void _showPaymentResult(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Completed'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info,
              color: Colors.blue,
              size: 64,
            ),
            SizedBox(height: 16),
            Text('You have returned from the payment process. Please check your payment status.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to Pay Fines page
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/pay-fines',
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show payment success dialog
  static void _showPaymentSuccess(BuildContext context, String? paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text('Your payment has been successfully processed.'),
            if (paymentId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Payment ID: $paymentId',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to home or success page
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show payment failure dialog
  static void _showPaymentFailure(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            Text('Your payment could not be processed. Please try again.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to Pay Fines page to retry
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/pay-fines',
                (route) => false,
              );
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
