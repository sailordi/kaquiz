import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaquiz/manager/userManager.dart';

import '../../models/userData.dart';
import '../../widgets/drawerWidget.dart';
import '../../widgets/locationWidget.dart';

class LocationsView extends ConsumerStatefulWidget {
  const LocationsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationsViewState();
}

class _LocationsViewState extends ConsumerState<LocationsView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  dynamic yourData(UserData data) {

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: CachedNetworkImage(
                imageUrl: data.profilePicUrl,
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
              Text("Name: ${data.userName}"),
              Text("Email: ${data.email}"),
              const SizedBox(width: 10,),
            ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10,),
            Text("Longitude: ${data.longitude}"),
            Text("Latitude: ${data.latitude}"),
            const SizedBox(width: 10,),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var userData = ref.watch(userDataManager);
    var friendsData = ref.watch(friendsManager);

      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Kaquiz: locations"),
          ),
          drawer: const DrawerWidget(),
          body:Column(
            children: [
             yourData(userData),
              const SizedBox(height: 20,),
              const Text("Friends:"),
              const SizedBox(height: 20,),
              Flexible(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: friendsData.length,
                    itemBuilder: (context,index) {
                      return Column(
                        children: [
                          LocationWidget(userData: friendsData[index]),
                          (friendsData.length-1 == index) ? const SizedBox() :
                          const SizedBox(height: 20,)
                        ],
                      );
                    }
                ),
              )
            ],
          )
      );
    }

}