import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tab_container/tab_container.dart';

import '../../manager/userManager.dart';
import '../../models/userData.dart';
import '../../widgets/drawerWidget.dart';
import '../../widgets/locationWidget.dart';

class LocationsView extends ConsumerStatefulWidget {
  const LocationsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationsViewState();
}

class _LocationsViewState extends ConsumerState<LocationsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  dynamic friendMap(Users friends) {

  }

  dynamic friendList(Users friends) {
    return Flexible(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: friends.length,
          itemBuilder: (context,index) {
            return Column(
              children: [
                LocationWidget(userData: friends[index]),
                (friends.length-1 == index) ? const SizedBox() :
                const SizedBox(height: 20,)
              ],
            );
          }
      ),
    );

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

  dynamic tabContainer(BuildContext context,Users friends) {
    return TabContainer(
      controller: _tabController,
      tabEdge: TabEdge.top,
      tabsStart: 0.1,
      tabsEnd: 0.9,
      tabMaxLength: 100,
      borderRadius: BorderRadius.circular(10),
      tabBorderRadius: BorderRadius.circular(10),
      childPadding: const EdgeInsets.all(20.0),
      selectedTextStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 15.0,
      ),
      unselectedTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 13.0,
      ),
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary,
      ],
      tabs: const [
        Text('Friend locations'),
        Text('Friends map'),
      ],
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: friendList(friends)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: friendMap(friends)
        ),
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
              const SizedBox(height: 10,),
              tabContainer(context,friendsData)
            ],
          )
      );
    }

}