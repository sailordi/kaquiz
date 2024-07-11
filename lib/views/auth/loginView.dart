   import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/helper.dart';
import '../../manager/userManager.dart';
import '../../widgets/expandedButtonWidget.dart';
import '../../widgets/textFieldWidget.dart';

class LoginView extends ConsumerStatefulWidget {
  final void Function()? tap;

  const LoginView({super.key, this.tap});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {

  void loginFirebase() async {
    try {
      await ref.read(userManager.notifier).logIn();
      if(mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch(e) {
      if(mounted) {
        Navigator.pop(context);
        Helper.messageToUser(e.code,context);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //App name
              const Text("Kaquiz",style: TextStyle(fontSize: 20) ),
              const SizedBox(height: 30,),
              //Login
              ExpandedButtonWidget(text: "Login with Google", tap: loginFirebase),
              const SizedBox(height: 15,),
              //Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.tap,
                    child: const Text(" Register here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
}