import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAdapter {
  static Future _getImage(ImageSource source,void Function(File) addFile) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      addFile(File(pickedFile.path) );
    }

  }

  static void showImageSourceDialog(BuildContext context,void Function(File) addFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select profile image source"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera,addFile);
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery,addFile);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

}