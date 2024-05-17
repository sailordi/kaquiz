import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/userData.dart';

class LocationWidget extends StatelessWidget {
  final UserData userData;

  const LocationWidget({super.key,required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: userData.profilePicUrl,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10,),
              Text("Name: ${userData.userName}"),
              Text("Email: ${userData.email}"),
              const SizedBox(width: 10,),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10,),
              Text("Longitude: ${userData.longitude}"),
              Text("Latitude: ${userData.latitude}"),
              const SizedBox(width: 10,),
            ],
          )
        ]
    );
  }

}
