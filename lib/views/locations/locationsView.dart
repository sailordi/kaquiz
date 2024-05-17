import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahoot/models/userData.dart';
import 'package:kahoot/widgets/locationWidget.dart';

import '../../manager/userManager.dart';
import '../../widgets/drawerWidget.dart';

class LocationsView extends ConsumerStatefulWidget {
  const LocationsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationsViewState();
}

class _LocationsViewState extends ConsumerState<LocationsView> {
  bool login = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _init();

    Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateLoc();
    });

  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _updateLoc() async {
  }

  void _init() async {
    await ref.read(userManager.notifier).loadData();
  }

  Future<void> removeFriend(String userId) async {

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
      var uM = ref.read(userManager);

      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Kahoot: locations"),
          ),
          drawer: const DrawerWidget(),
          body:Column(
            children: [
             yourData(uM.data),
              const SizedBox(height: 20,),
              const Text("Friends:"),
              const SizedBox(height: 20,),
              Flexible(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: uM.friends.length,
                    itemBuilder: (context,index) {
                      return Column(
                        children: [
                          LocationWidget(userData: uM.friends[index]),
                          (uM.friends.length-1 == index) ? const SizedBox() :
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