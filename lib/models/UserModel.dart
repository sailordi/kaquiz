import 'userData.dart';

typedef Contacts = List<UserData>;

typedef Users = List<UserData>;

class UserModel {
  UserData data;
  UserData? selectedUser;
  Users sentRequests;
  Users receivedRequests;
  Users friends;

  UserModel({required this.data,required this.selectedUser,required this.sentRequests,required this.receivedRequests,required this.friends});

  UserModel.empty() : data = UserData.empty(),selectedUser = null,sentRequests = [],receivedRequests = [],friends = [];

  UserModel.fresh({required this.data,required this.sentRequests,required this.receivedRequests,required this.friends}) : selectedUser = null;

  UserModel.moc(): data = UserData.moc1(),selectedUser = null,sentRequests = [UserData.moc2()],receivedRequests = [UserData.moc3()],friends = [UserData.moc4()];

  UserModel copyWith({UserData? data,UserData? selectedUser,Users? sentRequests,Users? receivedRequests,Users? friends}) {
    return UserModel(
        data: data ?? this.data,
        selectedUser: selectedUser ?? this.selectedUser,
        sentRequests: sentRequests ?? this.sentRequests,
        receivedRequests: receivedRequests ?? this.receivedRequests,
        friends: friends ?? this.friends
    );
  }

}