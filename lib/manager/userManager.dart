import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
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
  StreamSubscription<DatabaseEvent>? _friendStream;
  StreamSubscription<DatabaseEvent>? _receiverRequestsStream,_senderRequestsStream;

  UserManager(this.ref) : super(UserModel.empty() ){
    timerA = TimerAdapter(time: 5,onTiger: _timerFunctions);
  }

  Future<void> logIn(String email,String password) async {
    try {
      await firebaseA.logIn(email,password);
      await _initData();
    } on MyError catch (e) {
      throw MyError("Error: Could not login\n${e.text}");
    } on String catch(e) {
      throw MyError(e);
    }

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

  void logOut() {
    timerA.stop();
    _closeStreams();

    state = UserModel.empty();

    firebaseA.logOut();
  }

  Future<void> fetchFriends() async {
    timerA.trigger();
  }

  Future<void> fetchRequests() async {
    String id = state.data.id;

    List<Users> userL = await Future.wait([
      firebaseA.getRequests(id,sent: true),
      firebaseA.getRequests(id,sent: false),
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

  Future<UserData> sendRequest(int index) async {
    var foundU = state.foundUsers;

    try {
      await firebaseA.sendRequest(state.data.id,foundU.elementAt(index).id );
    } on String catch(e) {
      rethrow;
    }

    return foundU.elementAt(index);
  }

  Future<UserData> acceptRequest(int index) async {
    var rec = state.receivedRequests;

      await firebaseA.acceptRequests(state.data.id,rec.elementAt(index).id);

      return rec.elementAt(index);
  }

  Future<UserData> declineRequest(int index) async {
    var rec = state.receivedRequests;

      await firebaseA.declineRequests(state.data.id,rec.elementAt(index).id);

      return rec.elementAt(index);
  }

  Future<UserData> removeFriend(int index) async {
    var friends = state.friends;

      await firebaseA.removeFriend(state.data.id,friends.elementAt(index).id );

      return friends.elementAt(index);
  }

  Future<void> _initData() async {
    await _updateLocation();
    state = await firebaseA.getYourData();
    await _initStreams();

    timerA.start();
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

  Future<void> _initStreams() async {
    _friendStream = firebaseA.friendStream(state.data.id,(String userId) async {
      var friends = await firebaseA.getFriends(userId);

      state = state.copyWith(friends: friends);
    }
    );

    _senderRequestsStream = firebaseA.requestsStream(state.data.id,sent: true,(String userId) async {
      Users u = await firebaseA.getRequests(userId,sent: true);

      print("sent Triggered");

      state = state.copyWith(sentRequests: u);
    });

    _receiverRequestsStream = firebaseA.requestsStream(state.data.id,sent: true,(String userId) async {
      Users u = await firebaseA.getRequests(userId,sent: false);

      print("rec Triggered");

      state = state.copyWith(receivedRequests: u);
    });

  }

  Future<void> _closeStreams() async {
    if(_friendStream != null) {
      _friendStream?.cancel();
      _friendStream = null;
    }

    if(_receiverRequestsStream != null) {
      _receiverRequestsStream?.cancel();
      _receiverRequestsStream = null;
    }

    if(_senderRequestsStream != null) {
      _senderRequestsStream?.cancel();
      _senderRequestsStream = null;
    }

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