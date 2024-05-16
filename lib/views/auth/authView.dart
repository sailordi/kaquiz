import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/routePaths.dart';
import '../../manager/userManager.dart';
import 'loginView.dart';
import 'registerView.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  bool login = true;

  @override
  void initState() {
    super.initState();
  }

  void switchView() {
    setState(() {
      login = !login;
    });

  }

  void navigate(BuildContext context) async {
    await ref.read(userManager.notifier).loadData();
    if(context.mounted) {
      Navigator.pushNamed(context,RoutePaths.locations() );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot) {
            if(snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigate(context);
              });
              return const SizedBox();
            } else {
              if(login) {
                return LoginView(tap: switchView);
              }else {
                return RegisterView(tap: switchView);
              }

            }

          }
      ),
    );

  }

}