import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../adapters/firebaseAdapter.dart';
import '../adapters/locationAdapter.dart';
import '../adapters/timerAdapter.dart';
import '../models/myError.dart';
import '../models/userData.dart';
import '../models/userModel.dart';

class UserManager extends StateNotifier<UserModel> {
  final StateNotifierProviderRef ref;
  late FirebaseAdapter firebaseA = FirebaseAdapter();
  late TimerAdapter timerA;
  StreamSubscription<QuerySnapshot<Object?> >? _friendStream,_receivedRequestsStream,_sentRequestsStream;

  UserManager(this.ref) : super(UserModel.empty() ){
    timerA = TimerAdapter(minutes: 10,onTiger: _timerFunctions);
  }

  Future<void> logIn(String email,String password) async {
    String userId = "";

    try {
      userId = await firebaseA.logIn(email,password);
    } on MyError catch (e) {
      throw MyError("Error: Could not login\n${e.text}");
    } on String catch(e) {
      throw MyError(e);
    }

    _friendStream = firebaseA.friendStream(userId,(String userId) async {
      var friends = await firebaseA.getFriends(userId);

      state = state.copyWith(friends: friends);
    });

    _sentRequestsStream = firebaseA.sentRequestsStream(userId,(String userId) async {
      print("Sent stream user id: $userId");
      var req = await firebaseA.getRequests(userId,true);

      state = state.copyWith(sentRequests: req);
    });

    _receivedRequestsStream = firebaseA.receivedRequestsStream(userId,(String userId) async {
      var req = await firebaseA.getRequests(userId,false);

      state = state.copyWith(sentRequests: req);
    });

    timerA.start();
  }

  Future<void> register(String email,String password,String username,File? image) async {
    try {
      await firebaseA.register(email,password,username,image);
    } on MyError catch (e) {
      throw MyError("Error: Could not register\n${e.text}");
    } on String catch(e) {
      throw MyError(e);
    }

    await logIn(email,password);
  }

  Future<void> initData() async {
    await _updateLocation();
    state = await firebaseA.getYourData();
  }

  void logOut() {
    state = UserModel.empty();

    if(_friendStream != null) {
      _friendStream?.cancel();
      _friendStream = null;
    }
    if(_receivedRequestsStream != null) {
      _receivedRequestsStream?.cancel();
      _receivedRequestsStream = null;
    }
    if(_sentRequestsStream != null) {
      _sentRequestsStream?.cancel();
      _sentRequestsStream = null;
    }

    firebaseA.logOut();
  }

  Future<void> fetchFriends() async {
    timerA.trigger();
  }

  Future<void> _updateLocation() async {
    var pos = await LocationAdapter.determinePosition();
    String latitude = pos.latitude.toString(),longitude = pos.longitude.toString();

    await firebaseA.updateLocationWithAuth(latitude,longitude);
  }

  Future<void> _timerFunctions() async {
    UserData d = state.data;
    String userId = state.data.id;
    var pos = await LocationAdapter.determinePosition();

    d = d.copyWith(latitude: pos.latitude.toString(),longitude: pos.longitude.toString() );

    await firebaseA.updateLocation(userId,d.latitude,d.longitude);

    var friends = await firebaseA.getFriends(userId);

    state = state.copyWith(data: d,friends: friends);
  }

  Future<void> fetchRequests() async {
    String id = state.data.id;

    List<Users> userL = await Future.wait([
      firebaseA.getRequests(id,true),
      firebaseA.getRequests(id,false),
    ]);

    state = state.copyWith(receivedRequests: userL.last,sentRequests: userL.first);
  }

  Future<void> findUser(String find) async {
    if(find.isEmpty) {
      state = state.copyWith(foundUsers: []);
    }

    var users =  await firebaseA.findUsers(state.data.id,find);

    state = state.copyWith(foundUsers: users);
  }

  Future<void> sendRequest(int index) async {
    var sent = state.sentRequests;
    var foundU = state.foundUsers;

    try {
      await firebaseA.sendRequest(state.data.id,foundU.elementAt(index).id );

    } on String catch(e) {
      rethrow;
    }

    state = state.copyWith(sentRequests: sent);
  }

  Future<void> acceptRequest(int index) async {
    var rec = state.receivedRequests;
    var friends = state.friends;

      firebaseA.addFriend(state.data.id,rec.elementAt(index).id);
  }

  Future<void> declineRequest(int index) async {
    var rec = state.receivedRequests;

      await firebaseA.declineRequests(state.data.id,rec.elementAt(index).id);
  }

  Future<void> removeFriend(int index) async {
    var friends = state.friends;

      await firebaseA.removeFriend(state.data.id,friends.elementAt(index).id );
  }

}

final userDataManager = Provider<UserData>((ref) {
  final userModel = ref.watch(userManager);
  return userModel.data;
});

final receivedReqManager = Provider<Users>((ref) {
  final userModel = ref.watch(userManager);
  return userModel.receivedRequests;
});

final sentReqManager = Provider<Users>((ref) {
  final userModel = ref.watch(userManager);
  return userModel.sentRequests;
});

final friendsManager = Provider<Users>((ref) {
  final userModel = ref.watch(userManager);
  return userModel.friends;
});

final foundUsersManager = Provider<Users>((ref) {
  final userModel = ref.watch(userManager);
  return userModel.foundUsers;
});

final userManager = StateNotifierProvider<UserManager,UserModel>( (ref) {
  return UserManager(ref);
});