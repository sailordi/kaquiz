import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helper/routePaths.dart';
import '../manager/userManager.dart';

class DrawerWidget extends ConsumerStatefulWidget {
  const DrawerWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DrawerWidgetState ();

}

class _DrawerWidgetState extends ConsumerState<DrawerWidget> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                    child: SizedBox(
                      width: 1500,
                      height: 100,
                      child: Image.asset("assets/logo/logo.png"),
                    )
                ),
                const SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.home,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: const Text("L O C A T I O N S"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: const Text("I N V I T E S"),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(context,RoutePaths.invites() );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(Icons.wallet,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: const Text("L O G O U T"),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(userManager.notifier).logOut();
                  Navigator.pushReplacementNamed(context,RoutePaths.auth() );
                },
              ),
            )
          ],
        )
    );
  }

}