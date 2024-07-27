import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kaquiz/widgets/imageWidget.dart';

import '../models/userData.dart';
import '../widgets/buttonWidget.dart';

class FriendWidget extends StatelessWidget {
  final UserData user;
  final void Function()? remove;

  const FriendWidget({super.key,required this.user,this.remove});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black,
              width: 2
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        width: MediaQuery.of(context).size.width-20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageWidget(url: user.profilePicUrl, height: 50),
            const SizedBox(height: 5,),
            Text("Name: ${user.userName}",
              style: const TextStyle(
                  fontSize: 18
              ),
            ),
            const SizedBox(width: 5,),
            Text("Email: ${user.email}",
              style: const TextStyle(
                  fontSize: 18
              ),
            ),
            const SizedBox(height: 20),
            ButtonWidget(
                width: MediaQuery.of(context).size.width-70,
                height: 74.0,
                text: "Remove",
                tap: remove,
                color: Theme.of(context).colorScheme.inversePrimary,
                textColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
          ],
        )
    );


  }

}