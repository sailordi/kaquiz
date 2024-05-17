
String _mocProfilePic = "https://firebasestorage.googleapis.com/v0/b/kahoot-a7063.appspot.com/o/default.png?alt=media&token=ddc5c54a-1921-4332-82ce-40308ebf3809";

class UserData {
  final String id;
  final String userName;
  final String email;
  final String profilePicUrl;
  final String latitude;
  final String longitude;

  const UserData({required this.id,required this.userName,required this.email,required this.profilePicUrl,required this.latitude,required this.longitude});

  UserData.empty() : id = "",userName = "",email="",profilePicUrl = "",latitude="",longitude = "";

  UserData.fresh({required this.id,required this.userName,required this.email,required this.profilePicUrl}) : latitude="",longitude = "";

  UserData.moc1() : id= "moc1",userName="Sai",email="sai@test.com",profilePicUrl=_mocProfilePic,longitude = "1",latitude="1";
  UserData.moc2() : id= "moc2",userName="User2",email="user2@test.com",profilePicUrl=_mocProfilePic,longitude = "2",latitude="2";
  UserData.moc3() : id= "moc3",userName="User3",email="user3@test.com",profilePicUrl=_mocProfilePic,longitude = "3",latitude="3";
  UserData.moc4() : id= "moc4",userName="User4",email="user4@test.com",profilePicUrl=_mocProfilePic,longitude = "4",latitude="4";

  UserData copyWith({String? id,String? userName,String? email,String? profilePicUrl,String? latitude,String? longitude}) {
    return UserData(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude
    );

  }

}