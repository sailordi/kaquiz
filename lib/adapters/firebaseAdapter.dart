import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/userData.dart';
import '../../models/userModel.dart';


class FirebaseAdapter {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _users = FirebaseFirestore.instance.collection("users");
  final CollectionReference _requests = FirebaseFirestore.instance.collection("requests");
  final CollectionReference _locations = FirebaseFirestore.instance.collection("locations");

  FirebaseAdapter();

  CollectionReference _fiendRef(String userId) {
    return _users.doc(userId).collection("friends");
  }

  Future<void> register(String email,String password,String username,File? image) async {
    QuerySnapshot result = await _users
        .where("email", isEqualTo: email)
        .limit(1)  // We only need to check if at least one document exists
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isNotEmpty) {
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

      _users.doc(id).set({
        "id":id,
        "email":email,
        "username":username,
        "profileUrl":imageUrl,
      });

    } on FirebaseAuthException catch(e) {
      throw Exception(e.toString() );
    }

  }

  Future<String> logIn(String email,String password) async {
    QuerySnapshot result = await _users
        .where("email", isEqualTo: email)
        .limit(1)  // We only need to check if at least one document exists
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isNotEmpty) {
      throw "Error: Email is not registered can not log in";
    }

    try {
      var cred = await _auth.signInWithEmailAndPassword(email: email,password: password);
      String id = cred.user!.uid;

      return id;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.toString() );
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
    var friendsId = await _fiendRef(userId).get();

      for(var friendDoc in friendsId.docs) {
        var data = friendDoc.data() as Map<String, dynamic>;
        String friendId = data["id"];
        UserData f = await getUser(friendId,withLocation: true);

        ret.add(f);
      }

      return ret;
  }

  Future<void> updateLocation(String userId,String latitude,String longitude) async {
    _locations.doc(userId).set({
      "latitude":latitude,
      "longitude":longitude,
    });

  }

  Future<void>  addFriend(String userId,String friendId) async {
    var userF = _fiendRef(userId);
    var friendF = _fiendRef(friendId);
    var friend = await userF.doc(friendId).get();

    if(!friend.exists) {
      var user = await getUser(friendId);
      throw "Error: ${user.userName}(${user.email}) has already been added as a friend";
    }

    await Future.wait([
      userF.doc(friendId).set({"id":friendId}),
      friendF.doc(userId).set({"id":userId}),
    ]);

  }

  Future<void> removeFriend(String userId,String friendId) async {
    var userF = _fiendRef(userId);
    var friendF = _fiendRef(friendId);

    var friend = await userF.doc(friendId).get();

    if(!friend.exists) {
      var user = await getUser(friendId);
      throw "Error: ${user.userName}(${user.email}) has already been removed";
    }

    await Future.wait([
      userF.doc(friendId).delete(),
      friendF.doc(userId).delete(),
    ]);

  }

  StreamSubscription<QuerySnapshot<Object?> > friendStream(String userId,void Function(String) friendsChange) {
    return _fiendRef(userId).snapshots(includeMetadataChanges: false).listen(
            (event) { friendsChange(userId); },
            onError: (error) { print("Friend stream failed:\n$error"); }
    );

  }

  Future<void> sendRequest(String userId,String toId) async {
    var requestQ = await _requests.where('sender', isEqualTo: userId)
                          .where('receiver', isEqualTo: toId)
                          .get();
    var friendQ = await _fiendRef(userId).where('id', isEqualTo: toId)
                          .get();

    if(requestQ.docs.isNotEmpty) {
      var user = await getUser(toId);
      throw "Error: You have already sent request to ${user.userName}(${user.email})";
    }

    if(friendQ.docs.isNotEmpty) {
      var user = await getUser(toId);
      throw "Error: This user ${user.userName}(${user.email}) is already your friend";
    }

    await _requests.doc().set({"sender":userId,"receiver":toId});
  }

  Future<void> declineRequests(String userId,String friendId) async {
    var requestQ = await _requests.where('sender', isEqualTo: userId)
                          .where('receiver', isEqualTo: friendId)
                          .get();

    for(var d in requestQ.docs) {
      await d.reference.delete();
    }

  }

  Future<Users> getRequests(String id,bool sent) async        {
    Users ret = [];

    QuerySnapshot q;

      if(sent) {
        q = await _requests.where('sender', isEqualTo: id).get();
      } else {
        q = await _requests.where('receiver', isEqualTo: id).get();
      }

      for(var doc in q.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String senderId = data["sender"];
        String receiverId = data["receiver"];

        if(sent) {
          ret.add(await getUser(receiverId) );
        }else {
          ret.add(await getUser(senderId) );
        }

      }

      return ret;
  }

  StreamSubscription<QuerySnapshot<Object?> > receivedRequestsStream(String userId,void Function(String) receivedChange) {
    return _requests.where('receiver',isEqualTo: userId)
        .snapshots(includeMetadataChanges: false)
        .listen(
            (event) { receivedChange(userId); },
            onError: (error) { print("Friend stream failed:\n$error"); }
        );
  }

  StreamSubscription<QuerySnapshot<Object?> > sentRequestsStream(String userId,void Function(String) sentChange) {
    return _requests.where('sent',isEqualTo: userId)
        .snapshots(includeMetadataChanges: false)
        .listen(
            (event) { sentChange(userId); },
        onError: (error) { print("Friend stream failed:\n$error"); }
    );
  }

  Future<Users> findUsers(String user) async{
    QuerySnapshot querySnapshotEm = await _users.where('email', isEqualTo: user).get();
    QuerySnapshot querySnapshotUn = await _users.where('username', isEqualTo: user).get();

    Users ret = [];

      if(querySnapshotEm.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshotEm.docs.first;
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        String id = data["id"];
        String userName = data["username"];
        String email = data["email"];
        String profilePicUrl = data["profileUrl"];

          ret.add(UserData.fresh(
            id: id,
            userName: userName,
            email: email,
            profilePicUrl: profilePicUrl,
          )
        );

      }
      for(var doc in querySnapshotUn.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String id = data["id"];
        String userName = data["username"];
        String email = data["email"];
        String profilePicUrl = data["profileUrl"];

        ret.add(
          UserData.fresh(
            id: id,
            userName: userName,
            email: email,
            profilePicUrl: profilePicUrl,
          )
        );
      }

      return ret;
  }

  Future<UserData> getUser(String userId,{bool withLocation = false}) async {
    var doc = await _users.doc(userId).get();
    var data = doc.data() as Map<String, dynamic>;

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

    if(withLocation) {
      var docL = await _locations.doc(id).get();
      var lD = docL.data() as Map<String, dynamic>;

      ret = ret.copyWith(longitude: lD["longitude"],latitude: lD["latitude"]);
    }

    return ret;

  }

}