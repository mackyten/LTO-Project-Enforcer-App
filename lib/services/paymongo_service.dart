import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class PayMongoService {
  static const String _baseUrl = 'https://api.paymongo.com/v1';
  static String get _publicKey => dotenv.env['PAYMONGO_PUBLIC_KEY'] ?? '';
  static String get _secretKey => dotenv.env['PAYMONGO_SECRET_KEY'] ?? '';

  /// Creates a payment intent
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount, // Amount in centavos (e.g., 100 = 1 PHP)
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'amount': amount,
              'payment_method_allowed': ['gcash', 'grab_pay', 'card'],
              'payment_method_options': {
                'card': {'request_three_d_secure': 'automatic'},
              },
              'currency': currency,
              'capture_type': 'automatic',
              'description': description ?? 'LTO Fine Payment',
              'statement_descriptor': 'LTO PAYMENT',
              'metadata': metadata ?? {},
            },
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  /// Creates a payment method
  static Future<Map<String, dynamic>?> createPaymentMethod({
    required String type, // 'card', 'gcash', 'grab_pay'
    Map<String, dynamic>? details,
    Map<String, dynamic>? billing,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_publicKey:'))}',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'type': type,
              'details': details ?? {},
              'billing': billing,
            },
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment method: $e');
      return null;
    }
  }

  /// Attaches payment method to payment intent
  static Future<Map<String, dynamic>?> attachPaymentMethod({
    required String paymentIntentId,
    required String paymentMethodId,
    String? clientKey,
    String? returnUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/attach'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_publicKey:'))}',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'payment_method': paymentMethodId,
              'client_key': clientKey,
              'return_url': returnUrl ?? 'https://your-app.com/return',
            },
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error attaching payment method: $e');
      return null;
    }
  }

  /// Retrieves payment intent status
  static Future<Map<String, dynamic>?> getPaymentIntent(
    String paymentIntentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error retrieving payment intent: $e');
      return null;
    }
  }

  /// Creates a source for GCash/GrabPay payments
  static Future<Map<String, dynamic>?> createSource({
    required String type, // 'gcash' or 'grab_pay'
    required int amount,
    required String currency,
    required String internalId,
    Map<String, dynamic>? billing,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sources'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'type': type,
              'amount': amount,
              'currency': currency,
              'redirect': {
                'success': "https://lingayen-lto.web.app/success-payment?source_id=$internalId",
                'failed': "https://lingayen-lto.web.app/failed-payment?source_id=$internalId",
              },
              'billing': billing,
            },
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating source: $e');
      return null;
    }
  }

  /// Retrieves source status
  static Future<Map<String, dynamic>?> getSource(String sourceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sources/$sourceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error retrieving source: $e');
      return null;
    }
  }

  /// Retrieves payment details by payment ID
  static Future<Map<String, dynamic>?> getPayment(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error retrieving payment: $e');
      return null;
    }
  }

  /// List all payments (with optional filters)
  static Future<List<dynamic>?> listPayments({
    int? limit,
    String? before,
    String? after,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (before != null) queryParams['before'] = before;
      if (after != null) queryParams['after'] = after;

      String queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/payments${queryString.isNotEmpty ? '?$queryString' : ''}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error listing payments: $e');
      return null;
    }
  }

  /// Creates a payment using a source (for manual payment creation if needed)
  static Future<Map<String, dynamic>?> createPayment({
    required int amount,
    required String currency,
    required String sourceId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'amount': amount,
              'currency': currency,
              'description': description ?? 'LTO Fine Payment',
              'source': {'id': sourceId, 'type': 'source'},
              'metadata': metadata ?? {},
            },
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('PayMongo API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }
}
