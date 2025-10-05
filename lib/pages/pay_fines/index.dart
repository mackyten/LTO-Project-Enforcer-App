import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../shared/app_theme/colors.dart';
import '../../shared/app_theme/fonts.dart';
import '../../shared/decorations/app_bg.dart';
import '../../shared/components/textfield/app_input_border.dart';
import '../../utils/payment_handler.dart';
import '../violation/models/report_model.dart';

class PayFinesPage extends StatefulWidget {
  const PayFinesPage({super.key});

  @override
  State<PayFinesPage> createState() => _PayFinesPageState();
}

class _PayFinesPageState extends State<PayFinesPage> {
  final _formKey = GlobalKey<FormState>();
  final _trackingNumberController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isSearching = false;
  bool _isProcessingPayment = false;
  ReportModel? _foundReport;
  double _totalAmount = 0.0;

  @override
  void dispose() {
    _trackingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        title: Text(
          'Pay Fines',
          style: TextStyle(
            fontSize: FontSizes().h3,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appBg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: Colors.green, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Pay Your Fines',
                            style: TextStyle(
                              fontSize: FontSizes().h4,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Enter your violation tracking number to view and pay your outstanding fines securely.',
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          color: MainColor().textPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Tracking Number Input
                Text(
                  'Violation Tracking Number *',
                  style: TextStyle(
                    fontSize: FontSizes().body,
                    fontWeight: FontWeight.w600,
                    color: MainColor().textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _trackingNumberController,
                  style: TextStyle(color: MainColor().textPrimary),
                  decoration: appInputDecoration('Tracking Number').copyWith(
                    hintText: 'Enter violation tracking number',
                    prefixIcon: Icon(
                      Icons.track_changes,
                      color: MainColor().textPrimary,
                    ),
                    suffixIcon: _isSearching
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: MainColor().primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the violation tracking number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Clear previous results when user types
                    if (_foundReport != null) {
                      setState(() {
                        _foundReport = null;
                        _totalAmount = 0.0;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchViolation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MainColor().accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSearching
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Searching...'),
                            ],
                          )
                        : Text(
                            'Search Violation',
                            style: TextStyle(
                              fontSize: FontSizes().body,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Violation Details (shown after successful search)
                if (_foundReport != null) ...[
                  SizedBox(height: 30),
                  _buildViolationDetails(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViolationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Violation Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Violation Details',
                    style: TextStyle(
                      fontSize: FontSizes().h4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              _buildDetailRow(
                'Tracking Number',
                _foundReport!.trackingNumber ?? 'N/A',
              ),
              _buildDetailRow('Plate Number', _foundReport!.plateNumber),
              _buildDetailRow('Driver Name', _foundReport!.fullname),
              _buildDetailRow('License Number', _foundReport!.licenseNumber),
              _buildDetailRow('Status', _foundReport!.status),

              SizedBox(height: 12),
              Divider(color: Colors.white.withOpacity(0.3)),
              SizedBox(height: 12),

              Text(
                'Violations:',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),

              ..._foundReport!.violations
                  .map(
                    (violation) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              violation.violationName,
                              style: TextStyle(
                                fontSize: FontSizes().caption,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                          Text(
                            PaymentHandler.formatAmount(violation.price),
                            style: TextStyle(
                              fontSize: FontSizes().caption,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),

              SizedBox(height: 12),
              Divider(color: Colors.white.withOpacity(0.3)),
              SizedBox(height: 12),

              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    PaymentHandler.formatAmount(
                      PaymentHandler.calculateSubtotal(_foundReport!),
                    ),
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              // Processing Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Processing Fee (2.5%):',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    PaymentHandler.formatAmount(
                      PaymentHandler.calculateProcessingFee(
                        PaymentHandler.calculateSubtotal(_foundReport!),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Divider(color: Colors.white.withOpacity(0.3)),
              SizedBox(height: 8),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: FontSizes().h4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    PaymentHandler.formatAmount(_totalAmount),
                    style: TextStyle(
                      fontSize: FontSizes().h3,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Pay with GCash Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _isProcessingPayment ? null : _payWithGCash,
            icon: Icon(Icons.account_balance_wallet, size: 24),
            label: _isProcessingPayment
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Processing...'),
                    ],
                  )
                : Text(
                    'Pay with GCash ${PaymentHandler.formatAmount(_totalAmount)}',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 16),

        // Payment Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Payment Information',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• You will be redirected to GCash to complete payment\n'
                '• Payment is secure and encrypted\n'
                '• Once paid, your violation status will be updated\n'
                '• Keep your receipt for records',
                style: TextStyle(
                  fontSize: FontSizes().caption,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: FontSizes().caption,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: FontSizes().caption,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _searchViolation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSearching = true;
      _foundReport = null;
      _totalAmount = 0.0;
    });

    try {
      // Query Firebase for the report
      final querySnapshot = await _db
          .collection('reports')
          .where(
            'trackingNumber',
            isEqualTo: _trackingNumberController.text.trim(),
          )
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showErrorDialog(
          'Violation not found',
          'No violation found with tracking number "${_trackingNumberController.text}". Please check the number and try again.',
        );
        return;
      }

      // Get the report data
      final reportDoc = querySnapshot.docs.first;
      final reportData = reportDoc.data();

      // Convert to ReportModel
      final report = ReportModel.fromJson({...reportData, 'id': reportDoc.id});

      // Check if status is "Submitted"
      if (report.status != 'Submitted') {
        String message = 'Payment not allowed for this violation.\n\n';
        switch (report.status) {
          case 'Paid':
            message += 'This violation has already been paid.';
            break;
          case 'Cancelled':
            message += 'This violation has been cancelled.';
            break;
          case 'Overturned':
            message += 'This violation has been overturned.';
            break;
          default:
            message += 'Current status: ${report.status}';
        }

        _showErrorDialog('Payment Not Allowed', message);
        return;
      }

      // Calculate total amount including processing fee
      double totalWithFee = PaymentHandler.calculateTotalWithFee(report);

      setState(() {
        _foundReport = report;
        _totalAmount = totalWithFee;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Violation found! Total amount: ${PaymentHandler.formatAmount(totalWithFee)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error searching violation: $e');
      _showErrorDialog(
        'Search Error',
        'An error occurred while searching for the violation. Please try again.',
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _payWithGCash() async {
    if (_foundReport == null) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final internalId = _generateShortUniqueId();

      // Process GCash payment using PaymentHandler
      final result = await PaymentHandler.processGCashPayment(
        internalId: internalId,
        report: _foundReport!,
        context: context,
        redirectUrl: 'https://lto-enforcer.vercel.app/payment-return',
      );

      if (result != null && result['checkout_url'] != null) {
        // Store payment session in Firebase for tracking
        await _storePendingPayment(result, internalId);

        // Launch the GCash payment URL immediately
        await _launchPaymentUrl(result['checkout_url']);

        // Show brief success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirecting to GCash payment...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorDialog(
          'Payment Error',
          'Failed to initiate GCash payment. Please try again.',
        );
      }
    } catch (e) {
      print('Error processing GCash payment: $e');
      _showErrorDialog(
        'Payment Error',
        'An error occurred while processing your payment: $e',
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Try different launch modes to ensure the URL opens
      bool launched = false;

      // First try: External application (preferred for payments)
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('External app launch failed: $e');
      }

      // Second try: External non-browser mode
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        } catch (e) {
          print('External non-browser launch failed: $e');
        }
      }

      // Third try: Platform default
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      if (!launched) {
        throw Exception('Failed to launch payment URL with all methods');
      }
    } catch (e) {
      print('Error launching payment URL: $e');
      // Show error instead of fallback dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open payment page. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Store pending payment details in Firebase
  Future<void> _storePendingPayment(
    Map<String, dynamic> paymentResult,
    String internalId,
  ) async {
    try {
      final sourceId = paymentResult['source_id'];
      final currentUser = FirebaseAuth.instance.currentUser;
      
      final paymentData = {
        'paymentId': internalId,
        'sourceId': sourceId,
        'trackingNumber': _foundReport!.trackingNumber,
        'plateNumber': _foundReport!.plateNumber,
        'driverName': _foundReport!.fullname,
        'amount': _totalAmount,
        'status': 'Pending',
        'paymentMethod': 'GCASH',
        'violatorId': currentUser?.uid,
        'paidById': currentUser?.uid, // Add current user ID
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'violationTrackingNumber': _foundReport!.trackingNumber,
        'paymentResult': paymentResult,
        'reportId':
            _foundReport!.trackingNumber, // or use document ID if available
      };

      // Store pending payment
      await _db.collection('payments').doc(sourceId).set(paymentData);

      print('Pending payment stored: $sourceId');
    } catch (e) {
      print('Error storing pending payment: $e');
    }
  }

  /// Handle successful payment return
  // Future<void> handlePaymentReturn(String sourceId, {String? paymentId}) async {
  //   try {
  //     // Get transaction details
  //     final transactionDetails = await PaymentHandler.getTransactionDetails(
  //       sourceId,
  //     );

  //     if (transactionDetails != null && transactionDetails['success']) {
  //       // Update violation status to Paid
  //       await _updateViolationStatus(
  //         trackingNumber: _foundReport!.trackingNumber!,
  //         paymentDetails: transactionDetails,
  //       );

  //       // Update pending payment to completed
  //       await _db.collection('pending_payments').doc(sourceId).update({
  //         'status': 'completed',
  //         'payment_id': transactionDetails['payment_id'],
  //         'external_reference': transactionDetails['external_reference'],
  //         'completed_at': FieldValue.serverTimestamp(),
  //         'transactionDetails': transactionDetails,
  //       });

  //       // Show success message
  //       _showPaymentSuccessDialog(transactionDetails);
  //     } else {
  //       // Payment failed or pending
  //       _showPaymentFailedDialog();
  //     }
  //   } catch (e) {
  //     print('Error handling payment return: $e');
  //     _showErrorDialog('Error', 'Failed to process payment result: $e');
  //   }
  // }

  /// Update violation status in Firebase
  Future<void> _updateViolationStatus({
    required String trackingNumber,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      // Find and update the violation report
      final querySnapshot = await _db
          .collection('reports')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await _db.collection('reports').doc(docId).update({
          'status': 'Paid',
          'paymentStatus': 'Completed',
          'payment_id': paymentDetails['payment_id'],
          'external_reference': paymentDetails['external_reference'],
          'amount_paid': paymentDetails['amount'],
          'processing_fee': paymentDetails['fee'],
          'paid_at': FieldValue.serverTimestamp(),
        });

        print('Violation status updated to Paid: $trackingNumber');
      }
    } catch (e) {
      print('Error updating violation status: $e');
      throw e;
    }
  }

  /// Show payment success dialog
  void _showPaymentSuccessDialog(Map<String, dynamic> paymentDetails) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your violation fine has been paid successfully.'),
            SizedBox(height: 16),
            Text(
              'Transaction Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Payment ID: ${paymentDetails['payment_id']}'),
            if (paymentDetails['external_reference'] != null)
              Text('GCash Reference: ${paymentDetails['external_reference']}'),
            Text(
              'Amount Paid: ${PaymentHandler.formatAmount(paymentDetails['amount'] / 100)}',
            ),
            if (paymentDetails['fee'] != null)
              Text(
                'Processing Fee: ${PaymentHandler.formatAmount(paymentDetails['fee'] / 100)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show payment failed dialog
  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Payment Failed'),
          ],
        ),
        content: Text('Your payment could not be processed. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Generate a shorter but unique ID using timestamp + random characters
  String _generateShortUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    // Get last 6 digits of timestamp for uniqueness
    final timestampSuffix = (timestamp % 1000000).toString().padLeft(6, '0');
    
    // Generate 4 random characters
    final randomChars = String.fromCharCodes(Iterable.generate(
      4, (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));
    
    // Format: LTO-XXXXXX-YYYY (14 characters total)
    return 'ATF-$timestampSuffix-$randomChars';
  }
}
