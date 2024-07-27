import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


import '../models/userData.dart';
import 'buttonWidget.dart';
import 'imageWidget.dart';

class FoundUserWidget extends StatelessWidget {
  final UserData user;
  final void Function()? sendInvite;

  const FoundUserWidget({super.key,required this.user,this.sendInvite});

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageWidget(url: user.profilePicUrl, height: 70),
              const SizedBox(width: 5,),
              ButtonWidget(
                width: 300,
                height: 67,
                text: "Send invite",
                fontSize: 15,
                tap: sendInvite,
                color: Theme.of(context).colorScheme.inversePrimary,
                textColor: Theme.of(context).colorScheme.primary,
              )
            ],),
          const SizedBox(width: 5,),
          Text("Name: ${user.userName}"),
          Text("Email: ${user.email}"),
          const SizedBox(width: 10,),
        ],
      )
    );

  }

}