import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/violation/models/report_model.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Update report payment status after successful payment
  static Future<bool> updateReportPaymentStatus({
    required String trackingNumber,
    required String paymentId,
    required String paymentStatus,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      // Find the report by tracking number
      final querySnapshot = await _db
          .collection('reports')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Report not found');
      }

      final reportDoc = querySnapshot.docs.first;
      
      // Update the report with payment information
      await reportDoc.reference.update({
        'status': 'Paid',
        'paymentStatus': 'Completed',
        'paymentId': paymentId,
        'paymentCompletedAt': DateTime.now().toIso8601String(),
        'paymentDetails': paymentDetails ?? {},
      });

      print('Report payment status updated successfully');
      return true;
    } catch (e) {
      print('Error updating report payment status: $e');
      return false;
    }
  }

  /// Get payment status for a report
  static Future<Map<String, dynamic>?> getPaymentStatus(String trackingNumber) async {
    try {
      final querySnapshot = await _db
          .collection('reports')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final reportData = querySnapshot.docs.first.data();
      return {
        'status': reportData['status'] ?? 'Unknown',
        'paymentStatus': reportData['paymentStatus'] ?? 'Unknown',
        'paymentId': reportData['paymentId'],
        'paymentCompletedAt': reportData['paymentCompletedAt'],
      };
    } catch (e) {
      print('Error getting payment status: $e');
      return null;
    }
  }

  /// Create payment record for tracking
  static Future<String?> createPaymentRecord({
    required ReportModel report,
    required double amount,
    required String method,
    required String status,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final paymentRecord = {
        'trackingNumber': report.trackingNumber,
        'plateNumber': report.plateNumber,
        'driverName': report.fullname,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'violations': report.violations.map((v) => {
          'name': v.violationName,
          'price': v.price,
          'repetition': v.repetition,
        }).toList(),
        'paymentDetails': paymentDetails ?? {},
      };

      final docRef = await _db.collection('payments').add(paymentRecord);
      print('Payment record created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating payment record: $e');
      return null;
    }
  }

  /// Get payment history for a driver
  static Future<List<Map<String, dynamic>>> getPaymentHistory(String plateNumber) async {
    try {
      final querySnapshot = await _db
          .collection('payments')
          .where('plateNumber', isEqualTo: plateNumber)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }

  /// Calculate total penalties for a report
  static double calculateTotalAmount(ReportModel report) {
    double total = 0.0;
    for (var violation in report.violations) {
      total += violation.price;
    }
    return total;
  }

  /// Validate if report can be paid
  static bool canReportBePaid(ReportModel report) {
    return report.status == 'Submitted';
  }

  /// Get payment method display info
  static Map<String, dynamic> getPaymentMethodInfo(String method) {
    switch (method.toLowerCase()) {
      case 'gcash':
        return {
          'name': 'GCash',
          'icon': 'account_balance_wallet',
          'color': 'blue',
          'description': 'Pay with your GCash wallet',
        };
      case 'grab_pay':
        return {
          'name': 'GrabPay',
          'icon': 'local_taxi',
          'color': 'green',
          'description': 'Pay with your GrabPay wallet',
        };
      case 'card':
        return {
          'name': 'Credit/Debit Card',
          'icon': 'credit_card',
          'color': 'purple',
          'description': 'Pay with your credit or debit card',
        };
      default:
        return {
          'name': method,
          'icon': 'payment',
          'color': 'grey',
          'description': 'Payment method',
        };
    }
  }
}
