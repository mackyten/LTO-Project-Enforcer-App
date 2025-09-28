# PayMongo Transaction Numbers & Details

## **Available Transaction Identifiers:**

### **1. Source ID** (Immediate)
- **Format**: `src_abc123xyz789...`
- **When**: Available immediately after creating payment source
- **Usage**: Track payment session, check status

### **2. Payment ID** (After Success)
- **Format**: `pay_xyz789abc123...`
- **When**: Available after user completes payment
- **Usage**: Main transaction identifier, use for refunds/disputes

### **3. External Reference Number** (Provider Specific)
- **Format**: `GC12345678` (GCash), `GP87654321` (GrabPay)
- **When**: Available after successful payment
- **Usage**: Reference number from payment provider (GCash/GrabPay)

## **How to Get Transaction Details:**

### **Method 1: Using PaymentHandler.getTransactionDetails()**
```dart
// After user returns from payment
final transactionDetails = await PaymentHandler.getTransactionDetails(sourceId);

if (transactionDetails != null && transactionDetails['success']) {
  final paymentId = transactionDetails['payment_id'];
  final externalRef = transactionDetails['external_reference'];
  final amount = transactionDetails['amount'];
  final fee = transactionDetails['fee'];
  final paidAt = transactionDetails['paid_at'];
  
  print('Payment ID: $paymentId');
  print('GCash Reference: $externalRef');
  print('Amount Paid: ₱${amount / 100}');
  print('Processing Fee: ₱${fee / 100}');
}
```

### **Method 2: Using PayMongoService Directly**
```dart
// Get source status
final source = await PayMongoService.getSource(sourceId);
if (source['attributes']['status'] == 'chargeable') {
  // Payment successful
}

// Get specific payment details (if you have payment ID)
final payment = await PayMongoService.getPayment(paymentId);
final externalRef = payment['attributes']['external_reference_number'];
```

## **Complete Transaction Data Structure:**

```json
{
  "success": true,
  "status": "paid",
  "source_id": "src_abc123xyz789",
  "payment_id": "pay_xyz789abc123",
  "external_reference": "GC12345678",
  "amount": 150000,
  "fee": 2500,
  "net_amount": 147500,
  "paid_at": "2025-09-28T10:30:00Z",
  "payment_method": "gcash",
  "metadata": {
    "tracking_number": "TN123456",
    "plate_number": "ABC1234",
    "driver_name": "Juan Dela Cruz"
  }
}
```

## **Best Practice Implementation:**

### **1. Store Transaction Data in Firebase:**
```dart
// After successful payment
await FirebaseFirestore.instance
  .collection('transactions')
  .doc(paymentId)
  .set({
    'payment_id': paymentId,
    'source_id': sourceId,
    'external_reference': externalRef,
    'amount': amount,
    'tracking_number': trackingNumber,
    'paid_at': FieldValue.serverTimestamp(),
    'status': 'completed',
  });
```

### **2. Update Violation Status:**
```dart
// Update the violation report
await FirebaseFirestore.instance
  .collection('reports')
  .doc(reportId)
  .update({
    'status': 'Paid',
    'paymentStatus': 'Completed',
    'payment_id': paymentId,
    'external_reference': externalRef,
    'paid_at': FieldValue.serverTimestamp(),
  });
```

### **3. Generate Receipt:**
```dart
// Create receipt with all transaction details
final receipt = {
  'receipt_number': 'RCP${DateTime.now().millisecondsSinceEpoch}',
  'payment_id': paymentId,
  'external_reference': externalRef,
  'amount_paid': amount / 100,
  'processing_fee': fee / 100,
  'payment_method': 'GCash',
  'transaction_date': DateTime.now().toIso8601String(),
  'violation_details': violationData,
};
```

## **Transaction Numbers You Can Show Users:**

1. **Payment ID**: `pay_xyz789abc123` (PayMongo's main identifier)
2. **External Reference**: `GC12345678` (User-friendly GCash reference)
3. **Receipt Number**: `RCP1727516400000` (Your generated receipt number)

## **Usage in Your App:**

```dart
// In your payment success page
Text('Transaction Successful!');
Text('Payment ID: ${transactionDetails['payment_id']}');
Text('GCash Reference: ${transactionDetails['external_reference']}');
Text('Amount Paid: ₱${transactionDetails['amount'] / 100}');
```

This gives you complete transaction tracking capability with multiple reference numbers for different purposes!
