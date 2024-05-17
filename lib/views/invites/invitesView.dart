import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tab_container/tab_container.dart';

import '../../manager/userManager.dart';

class InvitesView extends ConsumerStatefulWidget {
  const InvitesView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvitesViewState();
}

class _InvitesViewState extends ConsumerState<InvitesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  dynamic tabContainer(BuildContext context) {
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
      ],
      tabs: const [
        Text('Sent'),
        Text('Received'),
        Text('Find user'),
      ],
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: const Text("Sent")
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: const Text("Rec")
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height-320,
            child: const Text("Find user")
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uM = ref.watch(userManager);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Kahoot: ${uM.data.userName}'s invites"),
      ),
      body: ListView(
        children: [
          tabContainer(context)
        ],
      ),
    );

  }

}