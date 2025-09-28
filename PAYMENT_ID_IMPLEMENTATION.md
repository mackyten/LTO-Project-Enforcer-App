# Payment ID Capture Implementation

## **How to Get Payment ID After Successful Payment**

I've implemented a comprehensive solution using **both approaches** for maximum reliability:

### **🔄 Complete Payment Flow:**

```
1. User clicks "Pay with GCash"
2. App creates source → Gets source_id
3. App stores pending payment in Firebase
4. User redirected to GCash → Completes payment
5. PayMongo redirects to: lingayen-lto.web.app/success-payment?source_id=xxx&payment_id=yyy
6. Web page triggers deep link: lto-enforcer://payment-return?source_id=xxx
7. App handles return → Gets transaction details → Updates Firebase
```

## **📱 App Implementation (Already Added):**

### **1. Store Pending Payment:**
```dart
// In _payWithGCash()
await _storePendingPayment(result);
// Stores: source_id, tracking_number, amount, status: "pending"
```

### **2. Handle Payment Return:**
```dart
// When user returns to app
await handlePaymentReturn(sourceId);
// Gets transaction details, updates violation status, shows success dialog
```

### **3. Transaction Details Retrieved:**
```dart
{
  'payment_id': 'pay_abc123...',
  'external_reference': 'GC12345678',
  'amount': 150000,
  'fee': 2500,
  'status': 'paid'
}
```

## **🌐 Web Page Template (lingayen-lto.web.app):**

### **success-payment.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Payment Successful</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <div style="text-align: center; padding: 50px; font-family: Arial;">
        <h2>✅ Payment Successful!</h2>
        <p>Redirecting back to LTO Enforcer app...</p>
        <div id="spinner">⏳</div>
    </div>

    <script>
        // Get URL parameters
        const urlParams = new URLSearchParams(window.location.search);
        const sourceId = urlParams.get('source_id');
        const paymentId = urlParams.get('payment_id');
        
        // Build deep link with parameters
        let deepLink = 'lto-enforcer://payment-return';
        if (sourceId) {
            deepLink += '?source_id=' + sourceId;
            if (paymentId) {
                deepLink += '&payment_id=' + paymentId;
            }
        }
        
        // Redirect to app immediately
        window.location.href = deepLink;
        
        // Fallback after 3 seconds
        setTimeout(() => {
            document.getElementById('spinner').innerHTML = 
                '<button onclick="window.location.href=\\'lto-enforcer://payment-return\\'" style="padding: 10px 20px; background: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer;">Open LTO Enforcer App</button>';
        }, 3000);
    </script>
</body>
</html>
```

### **failed-payment.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Payment Failed</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <div style="text-align: center; padding: 50px; font-family: Arial;">
        <h2>❌ Payment Failed</h2>
        <p>Redirecting back to LTO Enforcer app...</p>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const sourceId = urlParams.get('source_id');
        
        let deepLink = 'lto-enforcer://payment-return?status=failed';
        if (sourceId) {
            deepLink += '&source_id=' + sourceId;
        }
        
        window.location.href = deepLink;
    </script>
</body>
</html>
```

## **📊 Firebase Collections Created:**

### **1. `pending_payments` Collection:**
```json
{
  "source_id_abc123": {
    "source_id": "src_abc123...",
    "tracking_number": "TN123456",
    "plate_number": "ABC1234",
    "driver_name": "Juan Dela Cruz",
    "amount": 1500.00,
    "status": "pending",
    "payment_method": "gcash",
    "created_at": "2025-09-28T10:30:00Z"
  }
}
```

### **2. Updated `reports` Collection:**
```json
{
  "report_id": {
    "status": "Paid",
    "paymentStatus": "Completed",
    "payment_id": "pay_xyz789...",
    "external_reference": "GC12345678",
    "amount_paid": 150000,
    "processing_fee": 2500,
    "paid_at": "2025-09-28T10:35:00Z"
  }
}
```

## **✅ What You Get:**

1. **Payment ID**: `pay_xyz789abc123...` (stored in Firebase)
2. **GCash Reference**: `GC12345678` (shown to user)
3. **Complete Transaction Record**: Amount, fees, timestamps
4. **Updated Violation Status**: Automatically marked as "Paid"
5. **Receipt Data**: All details for generating receipts

## **🎯 User Experience:**

1. Tap "Pay with GCash" → Redirects to GCash
2. Complete payment → Success page appears briefly
3. Automatically returns to app → Success dialog with transaction details
4. Violation marked as paid → Receipt available

This gives you complete payment tracking with reliable transaction ID capture!
