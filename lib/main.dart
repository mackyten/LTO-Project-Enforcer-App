import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:enforcer_auto_fine/pages/home/index.dart';
import 'package:enforcer_auto_fine/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase initialized successfully!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<HomeBloc>(create: (context) => HomeBloc())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            // You can also add other properties here, such as:
            // labelStyle: TextStyle(color: Colors.deepPurple),
            // filled: true,
            // fillColor: Colors.grey[200],
          ),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const Wrapper(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
