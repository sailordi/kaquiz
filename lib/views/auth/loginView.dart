import 'package:flutter/cupertino.dart';
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
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  String errorCheck() {
    String ret = "";

    if(emailC.text.isEmpty) {
      if(ret.isNotEmpty) { ret += "\n"; }
      ret += "No email entered";
    }
    if(passwordC.text.isEmpty) {
      if(ret.isNotEmpty) { ret += "\n"; }
      ret += "No password entered";
    }

    return ret;
  }

  void login() async {
    Helper.circleDialog(context);

    String err = errorCheck();

    if(err.isNotEmpty) {
      Navigator.pop(context);

      Helper.messageToUser(err,context);

      return;
    }

    try {
      await ref.read(userManager.notifier).logIn(emailC.text,passwordC.text);
      if(mounted) {
        Navigator.pop(context);
      }
    } on Exception catch(e) {
      if(mounted) {
        Navigator.pop(context);
        Helper.messageToUser(e.toString(),context);
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
              //Email
              TextFieldWidget(hint: "Email", controller: emailC),
              const SizedBox(height: 10,),
              //Password
              TextFieldWidget(hint: "Password", controller: passwordC,obscure: true),
              const SizedBox(height: 15,),
              //Login
              ExpandedButtonWidget(text: "Login", tap: login),
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