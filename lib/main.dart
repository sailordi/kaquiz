import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahoot/views/invites/invitesView.dart';
import 'package:kahoot/views/locations/locationsView.dart';
import 'firebase_options.dart';

import '../../views/auth/authView.dart';
import 'helper/myTheme.dart';
import 'helper/routePaths.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
          title: 'Stock market',
          theme: MyTheme.lightMode(),
          darkTheme: MyTheme.darkMode(),
          initialRoute: RoutePaths.locations(),
          routes: {
            RoutePaths.auth(): (context) => const AuthView(),
            RoutePaths.locations(): (context) => const LocationsView(),
            RoutePaths.invites() : (context) => const InvitesView()
          },
          debugShowCheckedModeBanner: false,
        )
    );
  }
}
