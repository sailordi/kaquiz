import 'package:flutter/material.dart';

class MyTheme {

  static ThemeData darkMode() {
    return ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          background: Colors.grey.shade900,
          primary: Colors.grey.shade800,
          secondary: Colors.grey.shade700,
          inversePrimary: Colors.grey.shade500,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.grey[300],
            displayColor: Colors.white
        )
    );
  }

  static ThemeData lightMode() {
    return ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade300,
          primary: Colors.grey.shade200,
          secondary: Colors.grey.shade400,
          inversePrimary: Colors.grey.shade800,
        ),
        textTheme: ThemeData.light().textTheme.apply(
            bodyColor: Colors.grey[800],
            displayColor: Colors.black
        )
    );
  }

}