# Deep Link Configuration for Payment Returns

## Overview
This configuration allows the LTO Enforcer app to receive users back from PayMongo payment processing via custom URL scheme deep links.

## Configuration

### Custom URL Scheme
- **Scheme**: `lto-enforcer`
- **Payment Return URL**: `lto-enforcer://payment-return`

### Platform Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="lto-enforcer" />
</intent-filter>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>lto-enforcer</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>lto-enforcer</string>
        </array>
    </dict>
</array>
```

## How It Works

1. **Payment Initiation**: User starts payment process in the app
2. **External Browser**: PayMongo opens GCash/GrabPay in external browser/app
3. **Payment Completion**: User completes payment on external platform
4. **Deep Link Return**: PayMongo redirects to `lto-enforcer://payment-return`
5. **App Activation**: Custom URL scheme opens the LTO Enforcer app
6. **Route Handling**: App navigates to `/payment-return` route
7. **Result Display**: `PaymentReturnPage` shows payment result dialog
8. **Navigation**: User returns to appropriate page in the app

## Payment Flow

### GCash/GrabPay Payment Process:
```
LTO App → PayMongo Source → External Payment → Deep Link Return → LTO App
```

### Result Handling:
- **Success**: Green checkmark dialog → Navigate to Home
- **Failure**: Red error dialog → Navigate back to Pay Fines
- **Unknown**: Info dialog → Navigate to Pay Fines for status check

## Testing Deep Links

### Using ADB (Android):
```bash
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "lto-enforcer://payment-return" \
  com.example.enforcer_auto_fine
```

### Using Simulator (iOS):
```bash
xcrun simctl openurl booted "lto-enforcer://payment-return"
```

## Benefits

1. **Seamless UX**: Users return directly to the app after payment
2. **No Manual Navigation**: Automatic return eliminates user confusion  
3. **Status Handling**: Proper success/failure feedback
4. **Native Integration**: Works with both GCash and GrabPay apps
5. **Cross-Platform**: Consistent behavior on Android and iOS

## Important Notes

- The custom URL scheme must be unique to avoid conflicts
- Deep links work even when the app is backgrounded or closed
- PayMongo redirects to this URL after payment completion
- The app automatically shows appropriate success/failure dialogs
