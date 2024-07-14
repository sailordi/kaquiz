import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/userData.dart';
import '../widgets/buttonWidget.dart';
import 'imageWidget.dart';

class RequestWidget extends StatelessWidget {
  final UserData user;
  final bool received;
  final void Function()? accept;
  final void Function()? decline;

  const RequestWidget({super.key,required this.user,required this.received,this.accept,this.decline});

  dynamic buttons() {
    if(!received) {
      return const SizedBox();
    }
    return Row(
      children: [
        ButtonWidget(width: 50,text: "Accept",tap: accept),
        const SizedBox(width: 5,),
        ButtonWidget(width: 50,text: "Decline",tap: decline),
        const SizedBox(width: 10,),
      ],
    );
  }

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
        buttons()
      ],
    );

  }

}
