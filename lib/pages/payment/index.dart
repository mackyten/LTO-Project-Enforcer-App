import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../shared/app_theme/colors.dart';
import '../../shared/app_theme/fonts.dart';
import '../../shared/decorations/app_bg.dart';
import '../../utils/payment_handler.dart';
import '../violation/models/report_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final ReportModel report;

  const PaymentPage({super.key, required this.report});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  String? _selectedPaymentMethod;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    setState(() {
      _totalAmount = PaymentHandler.calculateTotalWithFee(widget.report);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        title: Text(
          'Payment',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Summary Card
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
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: FontSizes().h4,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    _buildSummaryRow(
                      'Tracking Number',
                      widget.report.trackingNumber ?? 'N/A',
                    ),
                    _buildSummaryRow('Plate Number', widget.report.plateNumber),
                    _buildSummaryRow('Driver Name', widget.report.fullname),

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

                    ...widget.report.violations
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
                            PaymentHandler.calculateSubtotal(widget.report),
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
                              PaymentHandler.calculateSubtotal(widget.report),
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

              SizedBox(height: 30),

              // Payment Methods
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: FontSizes().h4,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              _buildPaymentMethodCard(
                'gcash',
                'GCash',
                'Pay with your GCash wallet',
                Icons.account_balance_wallet,
                Colors.blue,
              ),

              SizedBox(height: 12),

              _buildPaymentMethodCard(
                'grab_pay',
                'GrabPay',
                'Pay with your GrabPay wallet',
                Icons.local_taxi,
                Colors.green,
              ),

              SizedBox(height: 12),

              _buildPaymentMethodCard(
                'card',
                'Credit/Debit Card',
                'Pay with your credit or debit card',
                Icons.credit_card,
                Colors.purple,
              ),

              SizedBox(height: 30),

              // Proceed to Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedPaymentMethod != null && !_isProcessing
                      ? _processPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColor().primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isProcessing
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
                            Text('Processing...'),
                          ],
                        )
                      : Text(
                          'Proceed to Pay ${PaymentHandler.formatAmount(_totalAmount)}',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20),

              // Payment Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Payment Information',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Payment processing is secure and encrypted\n'
                      '• You will be redirected to complete payment\n'
                      '• Payment confirmation will be sent via email\n'
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
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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

  Widget _buildPaymentMethodCard(
    String method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.white.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: FontSizes().caption,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      Map<String, dynamic>? result;
      final internalId = Uuid().v4();

      switch (_selectedPaymentMethod) {
        case 'gcash':
          result = await PaymentHandler.processGCashPayment(
            internalId: internalId,
            report: widget.report,
            context: context,
          );
          break;

        case 'card':
          result = await PaymentHandler.processCardPayment(
            report: widget.report,
            context: context,
          );
          break;
      }

      if (result != null) {
        // Handle successful payment initiation
        if (_selectedPaymentMethod == 'gcash' ||
            _selectedPaymentMethod == 'grab_pay') {
          // For wallet payments, redirect to checkout URL
          final checkoutUrl = result['attributes']['redirect']['checkout_url'];
          if (checkoutUrl != null) {
            await _launchPaymentUrl(checkoutUrl);
          }
        } else if (_selectedPaymentMethod == 'card') {
          // For card payments, you would typically show a card form
          // or redirect to a secure payment page
          _showCardPaymentDialog(result);
        }
      } else {
        _showErrorDialog('Failed to initiate payment. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Payment error: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Could not launch payment URL');
      }
    } catch (e) {
      _showErrorDialog('Error launching payment: $e');
    }
  }

  void _showCardPaymentDialog(Map<String, dynamic> paymentIntent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Colors.blue),
            SizedBox(width: 10),
            Text('Card Payment'),
          ],
        ),
        content: Text(
          'Payment Intent created successfully!\n\n'
          'Payment ID: ${paymentIntent['id']}\n'
          'Amount: ${PaymentHandler.formatAmount(_totalAmount)}\n\n'
          'In a production app, you would integrate with a secure card payment form here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Payment Error'),
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
}
