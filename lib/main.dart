import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/home/index.dart';
import 'package:enforcer_auto_fine/pages/profile/index.dart';
import 'package:enforcer_auto_fine/pages/violation/bloc/violation_bloc.dart';
import 'package:enforcer_auto_fine/pages/violation/index.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/pages/driver_registration/index.dart';
import 'package:enforcer_auto_fine/pages/appeal/index.dart';
import 'package:enforcer_auto_fine/pages/driver_appeals/index.dart';
import 'package:enforcer_auto_fine/pages/pay_fines/index.dart';
import 'package:enforcer_auto_fine/pages/payment_return/index.dart';

import 'routes.dart';


import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  print('Firebase initialized successfully!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ViolationBloc>(create: (context) => ViolationBloc()),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: MainColor().primary,
          ).copyWith(primary: MainColor().tertiary),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20.0,
                ), // Set the desired radius here
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20.0,
                ), // Set the desired radius
              ),
            ),
          ),

          useMaterial3: false,
        ),
        routes: {
          '/': (context) => const Wrapper(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const Profile(),
          '/driver-registration': (context) => const DriverRegistrationPage(),
          '/pay-fines': (context) => const PayFinesPage(),
          '/payment-return': (context) => const PaymentReturnPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/violations') {
            final initialData = settings.arguments as ReportModel?;
            return MaterialPageRoute(
              builder: (context) {
                return ViolationPage(initialData: initialData);
              },
            );
          }
          
          if (settings.name == '/appeal') {
            final trackingNumber = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) {
                return AppealPage(prefilledTrackingNumber: trackingNumber);
              },
            );
          }
          
          if (settings.name == '/driver-appeals') {
            return MaterialPageRoute(
              builder: (context) => const DriverAppealsPage(),
            );
          }
          
          // Try external routes for driver violations
          final externalRoute = AppRoutes.onGenerateRoute(settings);
          if (externalRoute != null) {
            return externalRoute;
          }
          
          // Handle other routes
          return null;
        },
      ),
    );
  }
}
