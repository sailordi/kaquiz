import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/userData.dart';
import '../../models/userModel.dart';
import '../models/myError.dart';

class FirebaseAdapter {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  DatabaseReference userTableRef() {
    return database.child("users");
  }

  DatabaseReference userRef(String userId) {
    return database.child("users/$userId");
  }

  DatabaseReference requestTableRef() {
    return database.child("requests");
  }

  DatabaseReference locationTableRef() {
    return database.child("locations");
  }

  DatabaseReference friendTableRef(String userId) {
    return database.child("users/$userId/friends");
  }

  FirebaseAdapter();

  Future<void> register(String email,String password,String username,File? image) async {
    final userSnapshot = await userTableRef().orderByChild("email").equalTo(email).get();

    if (userSnapshot.exists) {
      throw "Error: Email already registered";
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email,password: password);
      String id = cred.user!.uid;
      String imageUrl = "";
      UploadTask uploadTask;

      if(image == null) {
        var ref = _storage.ref().child('defaultProfileImage.png');
        imageUrl = await ref.getDownloadURL();
      }else {
        var ref = _storage.ref().child("profileImage").child(id);

        uploadTask = ref.putFile(image);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await userRef(id).set({
        "id":id,
        "email":email,
        "username":username,
        "profileUrl":imageUrl,
      });

    } on FirebaseAuthException catch(e) {
      throw MyError(e.code);
    }

  }

  Future<String> logIn(String email,String password) async {
    var doc = await userTableRef().orderByChild("email").equalTo(email).get();

    if(doc.value == null) {
      print("login ($email): exists:${doc.exists}, value:${doc.value}");
      throw "Error: Email is not registered can not log in";
    }

    try {
      var cred = await _auth.signInWithEmailAndPassword(email: email,password: password);
      String id = cred.user!.uid;

      return id;
    } on FirebaseAuthException catch (e) {
      throw MyError(e.code);
    }

  }

  Future<void> logOut() async {
    await _auth.signOut();
  }

  Future<UserModel> getYourData() async {
    var userId = _auth.currentUser!.uid;
    UserData data = await getUser(userId,withLocation: true);
    Users receivedRequests = [];
    Users sentRequests = [];
    Users friends = [];

    List<Users> userL = await Future.wait([
      getFriends(userId),
      getRequests(data.id,true),
      getRequests(data.id,false),
    ]);

    friends = userL.first;
    receivedRequests = userL.last;
    sentRequests = userL.elementAt(1);

    return UserModel.fresh(data: data,receivedRequests:  receivedRequests, sentRequests: sentRequests, friends: friends);
  }

  Future<Users> getFriends(String userId) async {
    Users ret = [];
    var friendsSnapshot = await friendTableRef(userId).get();

      for(var doc in friendsSnapshot.children) {
        if(doc.value == null) {
          print("Error: could not get doc value remove requests with userid\n$userId");
          continue;
        }

        var data =  Map<String, dynamic>.from(doc.value as dynamic);
        String friendId = data["id"];
        UserData f = await getUser(friendId, withLocation: true);

        ret.add(f);
      }

      return ret;
  }

  Future<void> updateLocation(String userId,String latitude,String longitude) async {
    await locationTableRef().child(userId).set({
      "latitude": latitude,
      "longitude": longitude,
    });

  }

  Future<void> updateLocationWithAuth(String latitude,String longitude) async {
    await updateLocation(_auth.currentUser!.uid,latitude,longitude);
  }

  Future<void>  addFriend(String userId,String friendId) async {
    var userF = friendTableRef(userId);
    var friendF = friendTableRef(friendId);
    var friendSnapshot = await userF.child(friendId).get();

    if (friendSnapshot.exists) {
      var user = await getUser(friendId);
      throw "Error: ${user.userName}(${user.email}) has already been added as a friend";
    }

    await Future.wait([
      userF.child(friendId).set({"id": friendId}),
      friendF.child(userId).set({"id": userId}),
    ]);

  }

  Future<void> removeFriend(String userId,String friendId) async {
    var userF = friendTableRef(userId);
    var friendF = friendTableRef(friendId);

    var friendSnapshot = await userF.child(friendId).get();

    if (!friendSnapshot.exists) {
      var user = await getUser(friendId);
      throw "Error: ${user.userName}(${user.email}) has already been removed";
    }

    await Future.wait([
      userF.child(friendId).remove(),
      friendF.child(userId).remove(),
    ]);

  }

  StreamSubscription<DatabaseEvent> friendStream(String userId,void Function(String) friendsChange) {
    return friendTableRef(userId).onValue.listen( (event) {
        friendsChange(userId);
      },
      onError: (error) {
        print("Friend stream failed:\n$error");
      },
    );

  }

  Future<void> sendRequest(String userId,String toId) async {
    var requestSnapshot = await requestTableRef().orderByChild('sender').equalTo(userId).get();
    var friendSnapshot = await friendTableRef(userId).orderByChild('id').equalTo(toId).get();

    if (requestSnapshot.exists) {
      var user = await getUser(toId);
      throw "Error: You have already sent request to ${user.userName}(${user.email})";
    }

    if (friendSnapshot.exists) {
      var user = await getUser(toId);
      throw "Error: This user ${user.userName}(${user.email}) is already your friend";
    }

    await requestTableRef().push().set({"sender": userId, "receiver": toId});
  }

  Future<void> declineRequests(String userId,String friendId) async {
    var requestSnapshot = await requestTableRef().orderByChild('sender').equalTo(userId).get();

      for (var doc in requestSnapshot.children) {
        if(!doc.exists) {
          print("Error: could not get doc remove requests with userid\n$userId");
          continue;
        }

        await doc.ref.remove();
      }

  }

  Future<Users> getRequests(String id,bool sent) async        {
    Users ret = [];
    Query query;

    if (sent) {
      query = requestTableRef().orderByChild('sender').equalTo(id);
    } else {
      query = requestTableRef().orderByChild('receiver').equalTo(id);
    }

    var requestSnapshot = await query.get();

    for (var doc in requestSnapshot.children) {
      if(doc.value == null) {
        print("Error: could not get doc value requests with userid\n$id");
        continue;
      }

      Map<String, dynamic> data =  Map<String, dynamic>.from(doc.value as dynamic);

      String senderId = data["sender"];
      String receiverId = data["receiver"];

      if (sent) {
        ret.add(await getUser(receiverId));
      } else {
        ret.add(await getUser(senderId));
      }

    }

    return ret;
  }

  StreamSubscription<DatabaseEvent> receivedRequestsStream(String userId,void Function(String) receivedChange) {
      return requestTableRef().orderByChild('receiver').equalTo(userId).onValue.listen( (event) {
          receivedChange(userId);
        },
        onError: (error) {
          print("Received requests stream failed:\n$error");
        },
      );
  }

  StreamSubscription<DatabaseEvent> sentRequestsStream(String userId,void Function(String) sentChange) {
      return requestTableRef().orderByChild('sender').equalTo(userId).onValue.listen( (event) {
          sentChange(userId);
        },
        onError: (error) {
          print("Sent requests stream failed:\n$error");
        },
      );
  }

  Future<Users> findUsers(String userId,String find) async{
    var emailQuerySnapshot = await userTableRef().orderByChild('email').equalTo(find).get();
    var usernameQuerySnapshot = await userTableRef().orderByChild('username').equalTo(find).get();

    Users ret = [];

    if (emailQuerySnapshot.exists) {
      if(emailQuerySnapshot.value == null) {
        print("Error: could not get value find user email userid/email\n$userId/$find");
      }else {
        var data =  Map<String, dynamic>.from(emailQuerySnapshot.value as dynamic);
        String id = data["id"];

        if (userId != id) {
          String userName = data["username"];
          String email = data["email"];
          String profilePicUrl = data["profileUrl"];

          ret.add(UserData.fresh(
            id: id,
            userName: userName,
            email: email,
            profilePicUrl: profilePicUrl,
          ));
        }

      }

    }

    for (var doc in usernameQuerySnapshot.children) {
      if(doc.value == null) {
        print("Error: could not get doc value find user with userid/username\n$userId/$find");
        continue;
      }

      Map<String, dynamic> data =  Map<String, dynamic>.from(doc.value as dynamic);
      String id = data["id"];

      if (id == userId) {
        continue;
      }

      String userName = data["username"];
      String email = data["email"];
      String profilePicUrl = data["profileUrl"];

      ret.add(UserData.fresh(
        id: id,
        userName: userName,
        email: email,
        profilePicUrl: profilePicUrl,
      ));
    }

    return ret;
  }

  Future<UserData> getUser(String userId,{bool withLocation = false}) async {
    var userSnapshot = await userRef(userId).get();

    if(!userSnapshot.exists) {
      print("Error: could not find user with id\n$userId");
      return UserData.empty();
    }

    if(userSnapshot.value == null) {
      print("Error: could not find user with id doc value null\n$userId");
      return UserData.empty();
    }

    var data = Map<String, dynamic>.from(userSnapshot.value as dynamic);

    String id = data["id"];
    String userName = data["username"];
    String email = data["email"];
    String profilePicUrl = data["profileUrl"];

    var ret = UserData.fresh(
      id: id,
      userName: userName,
      email: email,
      profilePicUrl: profilePicUrl,
    );

    if (withLocation) {
      var locationSnapshot = await locationTableRef().child(id).get();

      if(locationSnapshot.value == null) {
        print("Error: could not find user location with id doc value null\n$userId");
      }else {
        var lD =  Map<String, dynamic>.from(locationSnapshot.value as dynamic);

        ret = ret.copyWith(longitude: lD["longitude"], latitude: lD["latitude"]);
      }

    }

    return ret;
  }

}