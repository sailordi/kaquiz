import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class Helper {
  static void circleDialog(BuildContext context) {
    showDialog(context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        )
    );
  }

  static Future<File> loadImageAsFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath); // Load the image as bytes
    final file = File('${(await getTemporaryDirectory()).path}/tempImage.png'); // Create a temporary file
    await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)); // Write the bytes to the file

    return file; // Return the file
  }

  static void messageToUser(String str,BuildContext context) {
    showDialog(context: context,
        builder: (context) => Center(
            child: AlertDialog(
              title: Text(str),
            )
        )
    );
  }

}