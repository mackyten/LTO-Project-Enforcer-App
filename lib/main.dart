import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/home/index.dart';
import 'package:enforcer_auto_fine/pages/profile/index.dart';
import 'package:enforcer_auto_fine/pages/violation/bloc/violation_bloc.dart';
import 'package:enforcer_auto_fine/pages/violation/index.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Cloudinary.fromCloudName(cloudName: 'djw8sxxiy');

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
          colorScheme: ColorScheme.fromSeed(seedColor: MainColor().primary),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const Wrapper(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const Profile(),
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
          // Handle other routes
          return null;
        },
      ),
    );
  }
}
