import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/userData.dart';
import '../widgets/buttonWidget.dart';
import 'imageWidget.dart';

class FoundUserWidget extends StatelessWidget {
  final UserData user;
  final void Function()? sendInvite;

  const FoundUserWidget({super.key,required this.user,this.sendInvite});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10,),
        ImageWidget(url: user.profilePicUrl, height: 20),
        const SizedBox(width: 5,),
        Text("Name: ${user.userName}"),
        Text("Email: ${user.email}"),
        const SizedBox(width: 10,),
        ButtonWidget(width: 50,text: "Send invite",tap: sendInvite),
        const SizedBox(width: 10,),
      ],
    );

  }

}