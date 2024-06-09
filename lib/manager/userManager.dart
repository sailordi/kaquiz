import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/backendAdapter.dart';
import '../adapters/firebaseAdapter.dart';
import '../models/userModel.dart';


class UserManager extends StateNotifier<UserModel> {
  final StateNotifierProviderRef ref;
  late FirebaseAdapter firebaseA;
  final BackendAdapter backendA = BackendAdapter(8080);

  UserManager(this.ref) : super(UserModel.empty() ) {
      firebaseA = FirebaseAdapter(backendA: backendA);
  }

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