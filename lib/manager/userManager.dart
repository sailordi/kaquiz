import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../adapters/backendAdapter.dart';
import '../adapters/firebaseAdapter.dart';
import '../adapters/timerAdapter.dart';
import '../models/userModel.dart';


class UserManager extends StateNotifier<UserModel> {
  final StateNotifierProviderRef ref;
  late FirebaseAdapter firebaseA;
  final BackendAdapter backendA = BackendAdapter(8080);
  late TimerAdapter timerA;

  UserManager(this.ref) : super(UserModel.empty() ) {
      firebaseA = FirebaseAdapter(backendA: backendA);
      timerA = TimerAdapter(minutes: 10,onTiger: _fetchFriendsTimer);
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

      String? accessToken = auth?.accessToken;
      String? idToken = auth.idToken;

      final cred = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken
      );

      var userD = await _login(cred,email,accessToken!,idToken!);

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

      String? accessToken = auth?.accessToken;
      String? idToken = auth.idToken;

      final cred = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken
      );

      await firebaseA.register(cred,user.email,username,accessToken!,idToken!,image);

      var userD = await _login(cred,accessToken!,idToken!);

      state = userD;

      timerA.start();
    } catch(e) {
      throw "Error: Could not register with google\n${e.toString()}";
    }

  }

  void logOut() {
    timerA.stop();
    state = UserModel.empty();

    GoogleSignIn().signOut();
  }

  Future<UserModel> _login(AuthCredential credential,String email,String accessToken,String idToken) async {
    try {
      await firebaseA.logIn(credential,email);
    } catch(e) {
      rethrow;
    }

    String token = await backendA.authenticateUser(idToken);

    print("Token: $idToken\nReturn token: $token");

    var userD = await firebaseA.getYourData(idToken!);

    return userD.copyWith(accessToken: accessToken);
  }

  Future<void> fetchFriends() async {
    timerA.trigger();
  }

  Future<void> _fetchFriendsTimer() async {
    var data = await backendA.getFriendsLocations(state.accessToken);

    //TODO Friend data timer
  }

  Future<void> fetchRequests() async {
    var data = await backendA.getInvites(state.accessToken,state.data.id);

    //TODO Requests data
  }

}

final userManager = StateNotifierProvider<UserManager,UserModel>((ref) {
  return UserManager(ref);
});