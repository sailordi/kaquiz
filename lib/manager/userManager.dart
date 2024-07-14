import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';

import '../adapters/firebaseAdapter.dart';
import '../adapters/locationAdapter.dart';
import '../adapters/timerAdapter.dart';
import '../models/userData.dart';
import '../models/userModel.dart';

class UserManager extends StateNotifier<UserModel> {
  final StateNotifierProviderRef ref;
  late FirebaseAdapter firebaseA = FirebaseAdapter();
  late TimerAdapter timerA;

  UserManager(this.ref) : super(UserModel.empty() ){
    timerA = TimerAdapter(minutes: 10,onTiger: _timerFunctions);
  }

  Future<void> logIn() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();

      if(user == null) {
        throw "Error: Could not log in with google";
      }

      final GoogleSignInAuthentication? auth = await user?.authentication;

      if(auth == null) {
        throw "Error: Could not log in with google could not get auth";
      }

      String? email = user.email,id = user.id;
      String? accessToken = auth?.accessToken;
      String? idToken = auth.idToken;

      final cred = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken
      );

      var userD = await _login(cred,email,accessToken!,id);

      state = userD;

      timerA.start();
    }catch(e) {
      throw "Error: Could not log in with google\n${e.toString()}";
    }

  }

  Future<void> register(String username,File? image) async {

    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();

      if(user == null) {
        throw "Error: Could not log in with google";
      }

      final GoogleSignInAuthentication? auth = await user?.authentication;

      if(auth == null) {
        throw "Error: Could not log in with google could not get auth";
      }


      String email = user.email,id = user.id;
      String? accessToken = auth?.accessToken;
      String? idToken = auth.idToken;

      final cred = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken
      );

      await firebaseA.register(cred,email,username,accessToken!,id,image);

      var userD = await _login(cred,email,accessToken!,id);

      state = userD;

      timerA.start();
    } catch(e) {
      throw "Error: Could not register with google\n${e.toString()}";
    }

  }

  void logOut() {

    state = UserModel.empty();

    GoogleSignIn().signOut();
  }

  Future<UserModel> _login(AuthCredential credential,String email,String accessToken,String id) async {
    try {
      await firebaseA.logIn(credential,email);
    } catch(e) {
      rethrow;
    }

    var userD = await firebaseA.getYourData(id);

    return userD.copyWith(accessToken: accessToken);
  }

  Future<void> fetchFriends() async {
    timerA.trigger();
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

  Future<Users> findUser(String user) async {
    return await firebaseA.findUsers(user);
  }

  Future<void> sendRequest(String friendId) async {
    var sent = state.sentRequests;

    try {
      var ret = await firebaseA.sendRequest(state.data.id,friendId);

      sent.add(ret);
    } on String catch(e) {
      rethrow;
    }

    state = state.copyWith(sentRequests: sent);
  }

  Future<void> acceptRequest(int index) async {
    var rec = state.receivedRequests;

      await firebaseA.addFriend(state.data.id,rec.elementAt(index).id);

      await fetchRequests();
  }

  Future<void> declineRequest(int index) async {
    var rec = state.receivedRequests;

      await firebaseA.declineFriend(state.data.id,rec.elementAt(index).id);

      await fetchRequests();
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

final userManager = StateNotifierProvider<UserManager,UserModel>( (ref) {
  return UserManager(ref);
});