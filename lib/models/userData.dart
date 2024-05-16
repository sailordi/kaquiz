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