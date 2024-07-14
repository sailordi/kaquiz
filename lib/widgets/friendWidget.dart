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
    return Row(
      children: [
        const SizedBox(width: 10,),
        ImageWidget(url: user.profilePicUrl, height: 20),
        const SizedBox(width: 5,),
        Text("Name: ${user.userName}"),
        Text("Email: ${user.email}"),
        const SizedBox(width: 10,),
        ButtonWidget(width: 50,text: "Remove",tap: remove),
        const SizedBox(width: 10,),
      ],
    );

  }

}