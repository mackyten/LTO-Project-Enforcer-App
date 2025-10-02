import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/paymongo_service.dart';
import '../pages/violation/models/report_model.dart';

class PaymentHandler {
  /// Processing fee percentage (2.5%)
  static const double processingFeePercentage = 0.025;

  /// Calculate total amount for violations
  static double calculateTotalAmount(List<Map<String, dynamic>> violations) {
    double total = 0.0;
    for (var violation in violations) {
      total += (violation['price'] as double? ?? 0.0);
    }
    return total;
  }

  /// Calculate subtotal from ReportModel violations
  static double calculateSubtotal(ReportModel report) {
    double subtotal = 0.0;
    for (var violation in report.violations) {
      subtotal += violation.price;
    }
    return subtotal;
  }

  /// Calculate processing fee
  static double calculateProcessingFee(double subtotal) {
    return subtotal * processingFeePercentage;
  }

  /// Calculate total amount including processing fee
  static double calculateTotalWithFee(ReportModel report) {
    double subtotal = calculateSubtotal(report);
    double processingFee = calculateProcessingFee(subtotal);
    return subtotal + processingFee;
  }

  /// Convert PHP to centavos (PayMongo requires amounts in centavos)
  static int phpToCentavos(double phpAmount) {
    return (phpAmount * 100).round();
  }

  /// Check source status and get transaction details
  static Future<Map<String, dynamic>?> getTransactionDetails(String sourceId) async {
    try {
      // Get source status
      final source = await PayMongoService.getSource(sourceId);
      
      if (source != null) {
        final status = source['attributes']['status'];
        
        if (status == 'chargeable' || status == 'paid') {
          // Payment was successful, get payment details
          final payments = await _getPaymentsBySource(sourceId);
          
          if (payments != null && payments.isNotEmpty) {
            final payment = payments.first;
            
            return {
              'success': true,
              'status': 'paid',
              'source_id': sourceId,
              'payment_id': payment['id'],
              'external_reference': payment['attributes']['external_reference_number'],
              'amount': payment['attributes']['amount'],
              'fee': payment['attributes']['fee'],
              'net_amount': payment['attributes']['net_amount'],
              'paid_at': payment['attributes']['paid_at'],
              'payment_method': payment['attributes']['source']['type'],
              'metadata': payment['attributes']['metadata'],
            };
          }
        } else if (status == 'failed' || status == 'cancelled') {
          return {
            'success': false,
            'status': status,
            'source_id': sourceId,
          };
        } else {
          return {
            'success': false,
            'status': 'Pending',
            'source_id': sourceId,
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Error checking payment status: $e');
      return null;
    }
  }

  /// Get payments by source ID (helper method)
  static Future<List<dynamic>?> _getPaymentsBySource(String sourceId) async {
    try {
      // PayMongo doesn't have a direct API to get payments by source,
      // but you can store the payment ID when webhook is received
      // For now, we'll return null and rely on webhook data
      return null;
    } catch (e) {
      print('Error getting payments by source: $e');
      return null;
    }
  }

  /// Process GCash payment
  static Future<Map<String, dynamic>?> processGCashPayment({
    required ReportModel report,
    required BuildContext context,
    required String internalId,
    String? redirectUrl,
  }) async {
    try {
      // Calculate total amount including processing fee
      double totalAmount = calculateTotalWithFee(report);

      // Get current user's email
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email ?? '${report.licenseNumber.toLowerCase()}@lto-payment.ph';

      // Create source for GCash payment
      final source = await PayMongoService.createSource(
        internalId: internalId,
        type: 'gcash',
        amount: phpToCentavos(totalAmount),
        currency: 'PHP',
        billing: {
          'name': report.fullname,
          'email': userEmail,
          'phone': report.phoneNumber,
          'address': {
            'line1': report.address,
            'country': 'PH',
          },
        },
      );

      if (source != null) {
        // Return source for user to complete payment
        // PayMongo will automatically create the payment after user authorization
        return {
          'success': true,
          'source': source,
          'checkout_url': source['attributes']['redirect']['checkout_url'],
          'source_id': source['id'],
        };
      }

      return null;
    } catch (e) {
      print('Error processing GCash payment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process GCash payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }



  /// Process card payment using Payment Intent
  static Future<Map<String, dynamic>?> processCardPayment({
    required ReportModel report,
    required BuildContext context,
  }) async {
    try {
      // Calculate total amount including processing fee
      double totalAmount = calculateTotalWithFee(report);

      // Create payment intent
      final paymentIntent = await PayMongoService.createPaymentIntent(
        amount: phpToCentavos(totalAmount),
        currency: 'PHP',
        description: 'LTO Fine Payment - ${report.trackingNumber}',
        metadata: {
          'tracking_number': report.trackingNumber ?? '',
          'plate_number': report.plateNumber,
          'driver_name': report.fullname,
          'violation_count': report.violations.length.toString(),
        },
      );

      return paymentIntent;
    } catch (e) {
      print('Error processing card payment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process card payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Check payment status
  static Future<String?> checkPaymentStatus(String paymentId) async {
    try {
      final paymentIntent = await PayMongoService.getPaymentIntent(paymentId);
      return paymentIntent?['attributes']['status'];
    } catch (e) {
      print('Error checking payment status: $e');
      return null;
    }
  }

  /// Format amount for display
  static String formatAmount(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  /// Get payment method display name
  static String getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'gcash':
        return 'GCash';
      case 'grab_pay':
        return 'GrabPay';
      case 'card':
        return 'Credit/Debit Card';
      default:
        return method;
    }
  }
}
