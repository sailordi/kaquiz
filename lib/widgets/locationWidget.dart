import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/userData.dart';
import 'imageWidget.dart';

class LocationWidget extends StatelessWidget {
  final UserData userData;
  final double imageHeight;
  final bool withBorder;

  const LocationWidget({super.key,required this.userData,this.imageHeight = 50,this.withBorder = true});

  dynamic _widgetWithBorder(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black,
              width: 2
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        width: MediaQuery.of(context).size.width-20,
        child:  Column(
          children: [
            const SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageWidget(url: userData.profilePicUrl, height: imageHeight)
              ],
            ),
            const SizedBox(width: 10,),
            Text("Name: ${userData.userName}"),
            Text("Email: ${userData.email}"),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 10,),
                Text("Longitude: ${userData.longitude}"),
                Text("Latitude: ${userData.latitude}"),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 20,),
          ],
        )
    );

  }

  dynamic _widgetWithoutBorder(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width-20,
      child:  Column(
        children: [
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageWidget(url: userData.profilePicUrl, height: imageHeight)
            ],
          ),
          const SizedBox(width: 10,),
          Text("Name: ${userData.userName}"),
          Text("Email: ${userData.email}"),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10,),
              Text("Longitude: ${userData.longitude}"),
              Text("Latitude: ${userData.latitude}"),
              const SizedBox(width: 10,),
            ],
          ),
          const SizedBox(height: 20,),
        ],
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    if(withBorder) {
      return _widgetWithBorder(context);
    } else {
      return _widgetWithoutBorder(context);
    }

  }

}
