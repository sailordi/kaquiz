import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tab_container/tab_container.dart';

import '../../helper/helper.dart';
import '../../manager/userManager.dart';
import '../../models/userData.dart';
import '../../widgets/imageWidget.dart';
import '../../widgets/foundUserWidget.dart';
import '../../widgets/friendWidget.dart';
import '../../widgets/requestWidget.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  dynamic userFriends(BuildContext context,Users users) {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context,index) {
                return Column(
                  children: [
                    FriendWidget(user: users[index],
                        remove: () async {
                          try {
                            await ref.read(userManager.notifier).removeFriend(index);
                          } on String catch(e) {
                            if(context.mounted) {
                              Helper.messageToUser(e,context);
                            }

                          }
                        }
                    ),
                    (users.length-1 == index) ? const SizedBox() :
                    const SizedBox(height: 20,)
                  ],
                );
              }
          ),
        )
      ],
    );

  }

  dynamic sentRequests(Users users) {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context,index) {
                return Column(
                  children: [
                    RequestWidget(received: false,user: users[index],accept: () {  },decline: () {} ),
                    (users.length-1 == index) ? const SizedBox() :
                    const SizedBox(height: 20,)
                  ],
                );
              }
          ),
        )
      ],
    );

  }

  dynamic receivedRequest(Users users)  {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context,index) {
                return Column(
                  children: [
                    RequestWidget(received: true,user: users[index],
                      accept: () async {
                        await ref.read(userManager.notifier).acceptRequest(index);
                      },
                      decline: () async {
                        await ref.read(userManager.notifier).declineRequest(index);
                      }
                    ),
                    (users.length-1 == index) ? const SizedBox() :
                    const SizedBox(height: 20,)
                  ],
                );
              }
          ),
        )
      ],
    );
  }

  dynamic findUsers(BuildContext context,Users users) {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context,index) {
                return Column(
                  children: [
                    FoundUserWidget(user: users[index],
                        sendInvite: () async {
                          try {
                            await ref.read(userManager.notifier).sendRequest(index);
                          } on String catch(e) {
                            if(context.mounted) {
                              Helper.messageToUser(e,context);
                            }

                          }
                        }
                    ),
                    (users.length-1 == index) ? const SizedBox() :
                    const SizedBox(height: 20,)
                  ],
                );
              }
          ),
        )
      ],
    );

  }

  dynamic tabContainer(BuildContext context,Users friends,Users sent,Users receive,Users foundUsers) {
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
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary,
      ],
      tabs: const [
        Text('Friends'),
        Text('Received requests'),
        Text('Sent requests'),
        Text('Find user'),
      ],
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: userFriends(context,friends)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: receivedRequest(receive)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child:  sentRequests(sent)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: findUsers(context,foundUsers)
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final udM = ref.watch(userDataManager);
    final friendsM = ref.watch(friendsManager);
    final sentReqM = ref.watch(sentReqManager);
    final receivedReqM = ref.watch(receivedReqManager);
    final foundUsers = ref.watch(foundUsersManager);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Kahoot: ${udM.userName}(${udM.email})'s profile"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 5,),
          Row(
            children: [
              const SizedBox(width: 5,),
              ImageWidget(url: udM.profilePicUrl, height: 50),
              const SizedBox(width: 5,),
              Text("Friends: ${friendsM.length}"),
              const SizedBox(width: 5,),
              Text("Received requests: ${receivedReqM.length}"),
              const SizedBox(width: 5,),
              Text("Sent requests: ${sentReqM.length}"),
              const SizedBox(width: 5,),
            ],
          ),
          const SizedBox(height: 5,),
          tabContainer(context,friendsM,sentReqM,receivedReqM,foundUsers)
        ],
      ),
    );

  }

}