import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaquiz/widgets/imageWidget.dart';
import 'package:tab_container/tab_container.dart';

import '../../manager/userManager.dart';
import '../../models/userData.dart';
import '../../options.dart';
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

  Marker createMarker(UserData d) {
    return Marker(
          point: d.pos(),
          child: Row(
          children: [
            const Icon(
              Icons.pin_drop,
              color: Colors.red,
              size: 60,
            ),
            Text("${d.userName}(${d.email})")
          ],
        )
    );

  }

  dynamic friendMap(UserData user,Users friends) {
    List<Marker> markers = friends.map( (f) => createMarker(f) ).toList();

    markers.add(createMarker(user) );

    return Flexible(
        child: FlutterMap(
          options: MapOptions(
            initialCenter: user.pos(),
            initialZoom: 13.0,
            minZoom: 5,
            maxZoom: 18
          ), children: [
            TileLayer(
              urlTemplate: urlTemplate+accessToken,
              fallbackUrl: urlTemplate+accessToken,
              additionalOptions: const{
                'id':mapStyleOutdoor
              },
            ),
          MarkerLayer(markers: markers)
        ],
        )
    );

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
        const SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageWidget(url: data.profilePicUrl, height: 60)
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

  dynamic tabContainer(BuildContext context,UserData user,Users friends) {
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
            height: MediaQuery.of(context).size.height-350,
            child: friendList(friends)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-350,
            child: friendMap(user,friends)
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
              tabContainer(context,userData,friendsData)
            ],
          )
      );
    }

}