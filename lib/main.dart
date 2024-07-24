import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'adapters/locationAdapter.dart';
import 'firebase_options.dart';

import '../../helper/myTheme.dart';
import '../../helper/routePaths.dart';
import '../../views/profile/profileView.dart';
import '../../views/locations/locationsView.dart';
import '../../views/auth/authView.dart';
import 'options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  accessToken = dotenv.env['ACCESS_TOKEN'] ?? 'pk.eyJ1Ijoic2FpbG9yZGkiLCJhIjoiY2x5cDlzb3E2MGxpdzJvcGxtazB1YzhkYSJ9.HOdbObe6FDV7gfV2nv-DCQ';

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocationAdapter.determinePosition();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
          title: 'Kaquiz',
          theme: MyTheme.lightMode(),
          darkTheme: MyTheme.darkMode(),
          initialRoute: RoutePaths.auth(),
          routes: {
            RoutePaths.auth(): (context) => const AuthView(),
            RoutePaths.locations(): (context) => const LocationsView(),
            RoutePaths.profile() : (context) => const ProfileView()
          },
          debugShowCheckedModeBanner: false,
        )
    );

  }
}
