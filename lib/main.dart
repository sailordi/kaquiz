import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaquiz/consts.dart';

import 'adapters/locationAdapter.dart';
import 'firebase_options.dart';

import '../../helper/myTheme.dart';
import '../../helper/routePaths.dart';
import '../../views/profile/profileView.dart';
import '../../views/locations/locationsView.dart';
import '../../views/auth/authView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var pos = await LocationAdapter.determinePosition();

  firstLatitude = pos.latitude.toString();
  firstLongitude = pos.longitude.toString();

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
