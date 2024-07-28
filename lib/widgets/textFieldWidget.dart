import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;
  final TextAlign? align;

  const TextFieldWidget({super.key,required this.hint,this.obscure = false,required this.controller,this.align});

  @override
  Widget build(BuildContext context) {
    if(align == null) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)
            ),
            hintText: hint
        ),
        obscureText: obscure,
      );
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)
          ),
          hintText: hint
      ),
      obscureText: obscure,
      textAlign: align!,
    );

  }

}
