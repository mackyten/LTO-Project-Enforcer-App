# PayMongo Payment Flow Fix

## Issue Fixed
**Error**: "Source is not chargeable" when trying to create payments

## Root Cause
The previous implementation was trying to create a payment immediately after creating a source, but for GCash/GrabPay payments, the source needs to go through user authorization first.

## Incorrect Flow (Before Fix):
```
1. Create Source → 2. Immediately Create Payment (❌ FAILS)
```

## Correct Flow (After Fix):
```
1. Create Source → 2. User Authorizes Payment → 3. PayMongo Auto-Creates Payment ✅
```

## Changes Made

### 1. PaymentHandler Updates
- **GCash Payment**: Removed immediate payment creation, now returns source with checkout URL
- **GrabPay Payment**: Same fix as GCash
- **Return Format**: Now returns `{success: true, source: {...}, checkout_url: "...", source_id: "..."}`

### 2. PayMongoService Updates  
- **Added**: `getSource()` method to check source status
- **Kept**: `createPayment()` method for manual payment creation if needed
- **Hardcoded Redirects**: Using `lingayen-lto.web.app` URLs for success/failed redirects

### 3. Payment Process Flow
```dart
// 1. Create source and get checkout URL
final result = await PaymentHandler.processGCashPayment(...);

// 2. Launch checkout URL for user to complete payment
if (result != null && result['checkout_url'] != null) {
  await launchUrl(Uri.parse(result['checkout_url']));
}

// 3. After user completes payment, check source status
final source = await PayMongoService.getSource(result['source_id']);
// source['attributes']['status'] will be 'chargeable' when successful
```

## Key Points

### ✅ What Works Now:
- Source creation returns checkout URL immediately
- User can complete payment on GCash/GrabPay
- PayMongo automatically handles payment creation after authorization
- No more "source not chargeable" errors

### 🔄 User Experience:
1. User selects GCash/GrabPay payment
2. App creates source and gets checkout URL  
3. App opens checkout URL in browser/external app
4. User completes payment on GCash/GrabPay
5. User returns to app via redirect URL
6. App can check source status to confirm payment

### 🎯 Benefits:
- **No More Errors**: Eliminates "source not chargeable" issue
- **Proper Flow**: Follows PayMongo's intended payment process
- **Better UX**: Users complete payment in familiar GCash/GrabPay interface
- **Automatic Processing**: PayMongo handles payment creation after authorization

## Testing
The payment flow should now work without the "source not chargeable" error. Users will be able to complete GCash and GrabPay payments through the proper authorization flow.
