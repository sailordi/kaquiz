import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/imageAdapter.dart';
import '../../helper/helper.dart';
import '../../manager/userManager.dart';
import '../../widgets/buttonWidget.dart';
import '../../widgets/expandedButtonWidget.dart';
import '../../widgets/textFieldWidget.dart';

class RegisterView extends ConsumerStatefulWidget {
  final void Function()? tap;

  const RegisterView({super.key,this.tap});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();
  File? _profileImage;

  void _selectFile(File? f) {
    setState(() {
      _profileImage = f;
    });
  }

  String errorCheck() {
    String ret = "";

    if(usernameC.text.isEmpty) {
      ret += "Username is missing";
    }
    if(emailC.text.isEmpty) {
      if(ret.isNotEmpty) { ret += "\n"; }
      ret += "No email entered";
    }

    if(passwordC.text.isEmpty) {
      if(ret.isNotEmpty) { ret += "\n"; }
      ret += "No password entered";
    } else if(passwordC.text != confirmPasswordC.text) {
      if(ret.isNotEmpty) { ret += "\n"; }
      ret += "Passwords does not match";
    }

    return ret;
  }

  void registerFirebase() async {
    Helper.circleDialog(context);

    String err = errorCheck();

    if(err.isNotEmpty) {
      Navigator.pop(context);

      Helper.messageToUser(err,context);

      return;
    }

    try{
      await ref.read(userManager.notifier).register(usernameC.text,emailC.text,passwordC.text,_profileImage);
      if(mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch(e) {
      if(mounted) {
        Navigator.pop(context);
        Helper.messageToUser(e.code, context);
      }
    }

  }

  dynamic selectDeselectProfileImage() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(width: 189,text: "Select profile pic", tap: () {
            ImageAdapter.showImageSourceDialog(context,_selectFile);
          }
          ),
          ButtonWidget(width: 189,text: "Deselect profile pic", tap: () {
            _selectFile(null);
          }),
        ],
      );
  }

  dynamic profileImage() {
    if(_profileImage != null)  {
      return SizedBox(
          height: 190,
          child: Image.file(_profileImage!)
      );
    }
    return const SizedBox(
      height: 190,
      child: Text("No pic selected"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () {
              ImageAdapter.showImageSourceDialog(context,_selectFile);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //App name
              const Text("Secure message",style: TextStyle(fontSize: 20) ),
              const SizedBox(height: 30,),
              //Username
              TextFieldWidget(hint: "Username", controller: usernameC),
              const SizedBox(height: 10,),
              //Email
              TextFieldWidget(hint: "Email", controller: emailC),
              const SizedBox(height: 10,),
              //Password
              TextFieldWidget(hint: "Password", controller: passwordC,obscure: true),
              const SizedBox(height: 15,),
              //Password
              TextFieldWidget(hint: "Confirm password", controller: confirmPasswordC,obscure: true),
              const SizedBox(height: 15,),
              //Profile pic
              selectDeselectProfileImage(),
              const SizedBox(height: 5,),
             profileImage(),
              const SizedBox(height: 10,),
              ExpandedButtonWidget(text: "Register", tap: registerFirebase),
              const SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Have an account?"),
                  GestureDetector(
                    onTap: widget.tap,
                    child: const Text(" Login here",
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
