# Pay Fines Feature Documentation

## Overview
The Pay Fines feature allows drivers to pay their traffic violation fines using their violation tracking number. The system integrates with PayMongo for secure GCash payments.

## How It Works

### 1. Access Point
- Drivers can access the Pay Fines feature from the Driver Dashboard
- Click on the "Pay Fines" quick action card

### 2. Violation Search Process
1. **Enter Tracking Number**: Driver inputs their violation tracking number
2. **System Validation**: 
   - Searches Firebase 'reports' collection for matching tracking number
   - Validates report status (must be "Submitted")
   - Calculates total amount from all violations in the report

### 3. Status Validation Rules
The system only allows payment for violations with status = "Submitted"

**Rejected Statuses:**
- **"Paid"**: Already paid violations cannot be paid again
- **"Cancelled"**: Cancelled violations don't require payment
- **"Overturned"**: Overturned violations are dismissed

### 4. Payment Flow
1. **Violation Details Display**: Shows violation summary, driver info, and total amount
2. **GCash Payment**: Single "Pay with GCash" button for payment processing
3. **PayMongo Integration**: Creates GCash payment source and redirects to GCash
4. **Payment Completion**: User completes payment in GCash app/website

## Technical Implementation

### Files Structure
```
lib/pages/pay_fines/
├── index.dart                 # Main Pay Fines page
lib/services/
├── payment_service.dart       # Payment status management
├── paymongo_service.dart      # PayMongo API integration
lib/utils/
├── payment_handler.dart       # Payment processing logic
```

### Key Components

#### PayFinesPage (`/lib/pages/pay_fines/index.dart`)
- Form validation for tracking number input
- Firebase query to find violation reports
- Status validation logic
- Payment initiation with GCash
- Error handling and user feedback

#### PaymentService (`/lib/services/payment_service.dart`)
- Updates report status after successful payment
- Creates payment records for tracking
- Provides payment history functionality
- Validates payment eligibility

#### PayMongoService (`/lib/services/paymongo_service.dart`)
- Direct PayMongo API integration
- Creates payment sources for GCash
- Handles secure payment processing
- Environment-based configuration

## Database Schema

### Reports Collection Structure
```javascript
{
  "trackingNumber": "ABC123456",
  "plateNumber": "ABC1234",
  "fullname": "Juan Dela Cruz",
  "status": "Submitted",        // Required for payment
  "paymentStatus": "Pending",   // Updated after payment
  "violations": [
    {
      "violationName": "Speeding",
      "price": 500.00,
      "repetition": 1
    }
  ],
  // ... other fields
}
```

### Payments Collection (Created on Payment)
```javascript
{
  "trackingNumber": "ABC123456",
  "plateNumber": "ABC1234",
  "driverName": "Juan Dela Cruz",
  "amount": 500.00,
  "method": "gcash",
  "status": "completed",
  "createdAt": "2025-01-01T00:00:00Z",
  "violations": [...],
  "paymentDetails": {...}
}
```

## User Experience Flow

### 1. Driver Dashboard
```
[Pay Fines] Quick Action Card
     ↓
Pay Fines Page
```

### 2. Violation Lookup
```
Enter Tracking Number → [Search Violation] → Validation
                                              ↓
                                         Show Details
```

### 3. Payment Process
```
Violation Details → [Pay with GCash] → PayMongo → GCash App → Completion
```

## Error Handling

### User-Friendly Messages
- **"Violation not found"**: Invalid tracking number
- **"Payment not allowed"**: Wrong status (Paid/Cancelled/Overturned)
- **"Payment error"**: Technical issues during processing

### System Validation
- Form validation for required fields
- Network error handling
- PayMongo API error responses
- Firebase query error handling

## Security Features

### Data Protection
- Environment-based API key storage
- Secure HTTPS communication
- Input validation and sanitization
- User authentication required

### Payment Security
- PayMongo PCI-compliant processing
- Secure redirect to GCash
- No sensitive payment data stored locally
- Encrypted API communications

## Configuration Requirements

### Environment Variables (`.env`)
```
PAYMONGO_PUBLIC_KEY=pk_test_your_key_here
PAYMONGO_SECRET_KEY=sk_test_your_key_here
```

### Firebase Collections
- **reports**: Violation records
- **payments**: Payment transaction records

## Testing Guide

### Test Data Requirements
1. **Valid Report**: Status = "Submitted" with violations
2. **Invalid Reports**: Status = "Paid", "Cancelled", "Overturned"
3. **PayMongo Test Keys**: For payment processing

### Test Scenarios
1. **Valid Payment Flow**: Submitted violation → GCash payment
2. **Invalid Status**: Try paying already paid violation
3. **Non-existent Violation**: Invalid tracking number
4. **Network Issues**: Test offline/connection errors

## Production Checklist
- [ ] Replace test PayMongo keys with production keys
- [ ] Configure production webhooks for payment confirmation
- [ ] Set up proper return URLs
- [ ] Implement payment status updates
- [ ] Add receipt generation
- [ ] Configure error logging
- [ ] Test payment flows thoroughly

## Future Enhancements
- Multiple payment methods (Credit Card, GrabPay)
- Payment history page
- Automatic receipt generation
- SMS/Email payment confirmations
- Installment payment options
- Bulk payment for multiple violations
