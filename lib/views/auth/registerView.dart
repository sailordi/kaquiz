import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/imageAdapter.dart';
import '../../helper/helper.dart';
import '../../manager/userManager.dart';
import '../../models/myError.dart';
import '../../widgets/actionButton.dart';
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

  void _deselectFile() {
    _selectFile(null);
  }

  void _selectFile(File? f) {
    setState(() {
      _profileImage = f;
    });
  }

  String _errorCheck() {
    String ret = "";

    if(usernameC.text.isEmpty) {
      ret += "Username is missing";
    }
    if(passwordC.text.isEmpty) {
      ret += "Password is missing\n";
    }
    if(confirmPasswordC.text.isEmpty) {
      ret += "Confirm password is missing\n";
    }

    if(ret.isEmpty && passwordC.text != confirmPasswordC.text) {
      ret += "Password and confirm password does not match\n";
    }

    return ret;
  }

  void _registerFirebase() async {
    Helper.circleDialog(context);

    String err = _errorCheck();

    if(err.isNotEmpty) {
      Navigator.pop(context);

      Helper.messageToUser(err,context);

      return;
    }

    try{
      await ref.read(userManager.notifier).register(emailC.text,passwordC.text,usernameC.text,_profileImage);
      if(mounted) {
        Navigator.pop(context);
      }

    } on MyError catch(e) {
      if(mounted) {
        Navigator.pop(context);
        Helper.messageToUser(e.text, context);
      }

    }

  }

  dynamic _profileImageWidget() {
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
          ActionButtonWidget(text: "Register", tap: _registerFirebase),
          (_profileImage == null) ? const SizedBox() : ActionButtonWidget(text: "Deselect", tap: _deselectFile),
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
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //App name
                const Text("Kaquiz",style: TextStyle(fontSize: 20) ),
                const SizedBox(height: 5,),
                //Username
                TextFieldWidget(hint: "Username", controller: usernameC),
                const SizedBox(height: 5,),
                //Email
                TextFieldWidget(hint: "Email", controller: emailC),
                const SizedBox(height: 5),
                //Password
                TextFieldWidget(hint: "Password", controller: passwordC,obscure: true),
                const SizedBox(height: 5,),
                //Confirm Password
                TextFieldWidget(hint: "Confirm password", controller: confirmPasswordC,obscure: true),
                const SizedBox(height: 20,),
                _profileImageWidget(),
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
            )
          )
        )
      )
    );

  }

}