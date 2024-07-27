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

  dynamic buttons(BuildContext context) {
    if(!received) {
      return const SizedBox();
    }
    var width = MediaQuery.of(context).size.width-70;
    var height = 74.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 10,),
        ButtonWidget(
            width: width/2,
            height: height,
            text: "Accept",
            tap: accept,
            color: Theme.of(context).colorScheme.inversePrimary,
            textColor: Theme.of(context).colorScheme.primary,

        ),
        const SizedBox(width: 5,),
        ButtonWidget(
            width: width/2,
            height: height,
            text: "Decline",
            tap: decline,
            color: Theme.of(context).colorScheme.inversePrimary,
            textColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10,),
      ],
    );
  }

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
          (!received) ? const SizedBox() : const SizedBox(height: 20),
          buttons(context),
          (!received) ? const SizedBox() : const SizedBox(height: 20),
        ],
      )
    );

  }

}
