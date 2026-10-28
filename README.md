# LTO Enforcer App

[![CI](https://github.com/mackyten/LTO-Project-Enforcer-App/actions/workflows/ci.yml/badge.svg)](https://github.com/mackyten/LTO-Project-Enforcer-App/actions/workflows/ci.yml)

A Flutter mobile app for traffic enforcement. Enforcers record violations in the field, drivers review and pay their fines, and appeals are routed to administrators. The admin side lives in [LTO-Project-Admin-App](https://github.com/mackyten/LTO-Project-Admin-App).

## Features

- **Role-based access**: enforcers and drivers get different home screens and navigation drawers.
- **Violation reporting**: enforcers file reports with photo evidence.
- **Driver registration and profile**: drivers register and manage their own details.
- **Fines and payments**: drivers pay fines online through PayMongo (GCash, GrabPay, card).
- **Appeals**: drivers contest a violation; the outcome is tracked in the app.
- **Deep links**: payment providers return the user to the correct screen after checkout.

## Tech stack

- Flutter / Dart, with `flutter_bloc` for state management
- Firebase Auth and Cloud Firestore
- PayMongo, called directly over HTTP (no SDK), see [PAYMONGO_INTEGRATION.md](PAYMONGO_INTEGRATION.md)

## Project layout

```
lib/
  pages/       feature screens (violation, pay_fines, payment, appeal, profile, ...)
  services/    PayMongo and payment services
  shared/      theme, reusable components, helpers
  enums/       roles, Firestore collections
```

## Getting started

```bash
flutter pub get
flutter run
```

You need your own Firebase project (`flutterfire configure`) and a PayMongo test key. Keep keys out of version control.

## Further reading

- [PAYMONGO_INTEGRATION.md](PAYMONGO_INTEGRATION.md): payment flow and why it uses plain HTTP
- [PAY_FINES_DOCUMENTATION.md](PAY_FINES_DOCUMENTATION.md): how fines are paid
- [DEEP_LINK_SETUP.md](DEEP_LINK_SETUP.md): return-from-payment deep linking
- [VIOLATION_SYSTEM_UPDATE.md](VIOLATION_SYSTEM_UPDATE.md): violation model changes

## License

[MIT](LICENSE)
