import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaquiz/widgets/textFieldWidget.dart';
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
  final TextEditingController findUserC = TextEditingController();

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
        Row(
          children: [
            const Text("Search for user: "),
            TextFieldWidget(hint: "Username/email", controller: findUserC)
          ],
        ),
      ],
    );

  }

  dynamic tabContainer(BuildContext context,Users friends,Users sent,Users receive,Users foundUsers) {
    const heightRem = 239;

    return TabContainer(
      controller: _tabController,
      tabEdge: TabEdge.top,
      tabsStart: 0.1,
      tabsEnd: 0.9,
      tabMaxLength: 100,
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
            height: MediaQuery.of(context).size.height-heightRem,
            child: userFriends(context,friends)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child: receivedRequest(receive)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child:  sentRequests(sent)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
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
        title: Text("Kaquiz: ${udM.userName}(${udM.email})'s profile"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 5,),
          Row(
            children: [
              const SizedBox(width: 5,),
              ImageWidget(url: udM.profilePicUrl, height: 50),
              const SizedBox(width: 5,),
              Column(
                children: [
                  Text("Friends: ${friendsM.length}"),
                  const SizedBox(width: 5,),
                  Text("Received requests: ${receivedReqM.length}"),
                  const SizedBox(width: 5,),
                  Text("Sent requests: ${sentReqM.length}"),
                ],
              ),
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