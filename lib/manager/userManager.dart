import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/firebaseAdapter.dart';
import '../models/userModel.dart';


class UserManager extends StateNotifier<UserModel> {
  final StateNotifierProviderRef ref;
  final FirebaseAdapter firebaseA = FirebaseAdapter();

  UserManager(this.ref) : super(UserModel.empty() );

  Future<void> loadData() async {
    //state = await firebaseA.getYourData();
    state = UserModel.moc();
  }

  Future<void> logIn(String email,String password) async {
    await firebaseA.login(email, password);
  }

  Future<void> register(String username,String email,String password,File? image) async {
    await firebaseA.register(username,email, password,image);
  }

  void logOut() {
    state = UserModel.empty();

    firebaseA.logOut();
  }

}

final userManager = StateNotifierProvider<UserManager,UserModel>((ref) {
  return UserManager(ref);
});