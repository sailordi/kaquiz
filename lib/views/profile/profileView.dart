import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tab_container/tab_container.dart';

import '../../helper/helper.dart';
import '../../manager/userManager.dart';
import '../../models/userData.dart';
import '../../widgets/expandedButtonWidget.dart';
import '../../widgets/imageWidget.dart';
import '../../widgets/foundUserWidget.dart';
import '../../widgets/friendWidget.dart';
import '../../widgets/requestWidget.dart';
import '../../widgets/textFieldWidget.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _findUserC = TextEditingController();

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

  Future<void> _sendInvite(int index,BuildContext context) async {
    UserData? friend;
    try {
      friend = await ref.read(userManager.notifier).sendRequest(index);
    } on String catch (e) {
      if(context.mounted) {
        Helper.messageToUser(e, context);
      }
      return;
    }

    if(context.mounted) {
      Helper.messageToUser("Sent friend request to:\n${friend.userName} (${friend.email})", context);
    }

  }

  Future<void> _acceptInvite(int index,BuildContext context) async {
    UserData? user;
    try {
      user = await ref.read(userManager.notifier).acceptRequest(index);
    } on String catch (e) {
      if(context.mounted) {
        Helper.messageToUser(e, context);
      }
      return;
    }

    if(context.mounted) {
      Helper.messageToUser("Accepted friend request from:\n${user.userName} (${user.email})", context);
    }
  }

  Future<void> _declineInvite(int index,BuildContext context) async {
    UserData? user;
    try {
      user = await ref.read(userManager.notifier).declineRequest(index);
    } on String catch (e) {
      if(context.mounted) {
        Helper.messageToUser(e, context);
      }
      return;
    }

    if(context.mounted) {
      Helper.messageToUser("Declined friend request from:\n${user.userName} (${user.email})", context);
    }

  }

  Future<void> _removeFriend(int index,BuildContext context) async {
    UserData? user;
    try {
      user = await ref.read(userManager.notifier).removeFriend(index);
    } on String catch (e) {
      if(context.mounted) {
        Helper.messageToUser(e, context);
      }
      return;
    }

    if(context.mounted) {
      Helper.messageToUser("Removed friend:\n${user.userName} (${user.email})", context);
    }
  }

  dynamic _userFriends(BuildContext context,Users users) {
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
                        remove: () async { await _removeFriend(index, context); }
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

  dynamic _sentRequests(Users users) {
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

  dynamic _receivedRequest(Users users)  {
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
                      accept: () async { await _acceptInvite(index,context); },
                      decline: () async { await _declineInvite(index,context); }
                    ),
                    (users.length-1 == index) ? const SizedBox() :
                    const SizedBox(height: 20,)
                  ],
                );
              }
          ),
        ),
      ],
    );
  }

  dynamic _findUserList(Users users) {
    if(users.isEmpty && _findUserC.text.isEmpty) {
      return const SizedBox();
    }
    if(users.isEmpty && _findUserC.text.isNotEmpty) {
      return Text("User with username/email ${_findUserC.text} could be found");
    }
    return Flexible(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context,index) {
            return Column(
              children: [
                FoundUserWidget(
                  user: users[index],
                  sendInvite: () async { await _sendInvite(index,context); },
                ),
                (index != users.length-1) ? const SizedBox(height: 20,) : const SizedBox(),
              ],
            );
          }
      ),
    );
  }

  dynamic _findUsers(BuildContext context,Users users) {
    return Column(
      children: [
            const Text("Search for user: ",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5,),
            (context.mounted == false) ? const SizedBox() :
            TextFieldWidget(
                hint: "Username/email",
                controller: _findUserC,
              align: TextAlign.center,
            ),
            const SizedBox(height: 5,),
            SizedBox(
              height: 67,
              child: ExpandedButtonWidget(
                text: "Find user",
                fontSize: 15,
                tap: () async { await ref.read(userManager.notifier).findUser(_findUserC.text); },
                color: Theme.of(context).colorScheme.inversePrimary,
                textColor: Theme.of(context).colorScheme.primary,
              )
            ),
            const SizedBox(height: 50,),
            _findUserList(users),
            const SizedBox(height: 5,),
        ],
    );

  }

  dynamic _tabContainer(BuildContext context,Users friends,Users sent,Users receive,Users foundUsers) {
    const heightRem = 300;

    print("(profileView) rec: ${receive.length} sent: ${sent.length}");

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
        Text('Find users'),
      ],
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child: _userFriends(context,friends)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child: _receivedRequest(receive)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child:  _sentRequests(sent)
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-heightRem,
            child:  _findUsers(context,foundUsers)
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
        title: const Text("Kaquiz: profile"),
      ),
      body: SingleChildScrollView(
          child:  Column(
            children: [
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 5,),
                  ImageWidget(url: udM.profilePicUrl, height: 50),
                  const SizedBox(width: 5,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Username: ${udM.userName}"),
                      const SizedBox(width: 40,),
                      Text("Email: ${udM.email}"),
                      const SizedBox(width: 40,),
                      Text("Friends: ${friendsM.length}"),
                      const SizedBox(width: 40,),
                      Text("Received requests: ${receivedReqM.length}"),
                      const SizedBox(width: 40,),
                      Text("Sent requests: ${sentReqM.length}"),
                    ],
                  ),
                  const SizedBox(width: 5,),
                ],
              ),
              const SizedBox(height: 5,),
              _tabContainer(context,friendsM,sentReqM,receivedReqM,foundUsers)
            ],
          )
      )
    );

  }

}