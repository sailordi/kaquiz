import 'package:firebase_auth/firebase_auth.dart';

import 'userData.dart';

class UserModel {
  UserData data;
  UserData? selectedUser;
  Users sentRequests;
  Users receivedRequests;
  Users friends;
  Users foundUsers;
  String accessToken;

  UserModel({required this.data,required this.accessToken,required this.selectedUser,required this.sentRequests,required this.receivedRequests,required this.friends,required this.foundUsers});

  UserModel.empty() : data = UserData.empty(),accessToken = "",selectedUser = null,sentRequests = [],receivedRequests = [],friends = [],foundUsers = [];

  UserModel.fresh({required this.data,this.accessToken = "",required this.sentRequests,required this.receivedRequests,required this.friends}) : selectedUser = null,foundUsers = [];

  UserModel.moc(): data = UserData.moc1(),accessToken = "",selectedUser = null,sentRequests = [UserData.moc2()],receivedRequests = [UserData.moc3()],friends = [UserData.moc4()],foundUsers = [];

  UserModel copyWith({UserData? data,String? accessToken,UserData? selectedUser,Users? sentRequests,Users? receivedRequests,Users? friends,Users? foundUsers}) {
    return UserModel(
        data: data ?? this.data,
        accessToken: accessToken ?? this.accessToken,
        selectedUser: selectedUser ?? this.selectedUser,
        sentRequests: sentRequests ?? this.sentRequests,
        receivedRequests: receivedRequests ?? this.receivedRequests,
        friends: friends ?? this.friends,
        foundUsers: foundUsers ?? this.foundUsers
    );

  }

}