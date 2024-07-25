import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaquiz/helper/helper.dart';
import 'package:kaquiz/widgets/imageWidget.dart';
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

  Marker _createMarker(UserData d) {
    return Marker(
          markerId: MarkerId("${d.userName}(${d.email})"),
          onTap: () { Helper.messageToUser("Location lat/long:\n${d.pos().latitude}/${d.pos().longitude}",context); },
          icon: BitmapDescriptor.defaultMarker,
          position: d.pos(),
    );

  }

  dynamic _friendMap(UserData user,Users friends) {
    Set<Marker> markers = friends.map( (f) => _createMarker(f) ).toSet();

    markers.add(_createMarker(user) );

    return Flexible(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: user.pos(),
            zoom: 13.0
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(5,18),
          markers: markers,
        ),
    );

  }

  dynamic _friendList(Users friends) {
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

  dynamic _yourData(UserData data) {

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

  dynamic _tabContainer(BuildContext context,UserData user,Users friends) {
    const heightRem = 302;

    return TabContainer(
      controller: _tabController,
      tabEdge: TabEdge.top,
      tabsStart: 0.1,
      tabsEnd: 0.9,
      tabMaxLength: 120,
      borderRadius: BorderRadius.circular(2),
      tabBorderRadius: BorderRadius.circular(2),
      childPadding: const EdgeInsets.all(10.0),
      selectedTextStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 15.0,
      ),
      unselectedTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary,
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
            height: MediaQuery.of(context).size.height-heightRem,
            child: _friendList(friends)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child: _friendMap(user,friends)
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
             _yourData(userData),
              const SizedBox(height: 10,),
              _tabContainer(context,userData,friendsData)
            ],
          )
      );
    }

}