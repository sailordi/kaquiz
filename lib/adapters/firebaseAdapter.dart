import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kahoot/adapters/backendAdapter.dart';
import '../../models/userData.dart';
import '../../models/userModel.dart';


class FirebaseAdapter {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _users = FirebaseFirestore.instance.collection("users");
  final BackendAdapter backendA;

  FirebaseAdapter({required this.backendA});

  CollectionReference _fiendRef(String userId) {
    return _users.doc(userId).collection("friends");
  }

  Future<void> register(String username,String email,String password,File? image) async {
    try {
      UserCredential c = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String id = c.user!.uid;
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
      rethrow;
    }

  }

  Future<void> login(String user,String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: user,password: password);
    } on FirebaseAuthException catch(e) {
      rethrow;
    }
  }

  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<UserModel> getYourData() async {
    var userId = _auth.currentUser!.uid;
    UserData data = await getUser(userId);
    var friendsId = await _fiendRef(userId).get();
    Users receivedRequests = [];
    Users sentRequests = [];
    Users friends = [];



    for(var friendDoc in friendsId.docs) {
      var data = friendDoc.data() as Map<String, dynamic>;
      String friendId = data["id"];
      UserData f = await getUser(friendId);
      friends.add(f);
    }

    return UserModel.fresh(data: data,receivedRequests:  receivedRequests, sentRequests: sentRequests, friends: friends);
  }

  Future<List<UserData> > otherUsers(String user) async{
    QuerySnapshot querySnapshotEm = await _users.where('email', isEqualTo: user).get();
    QuerySnapshot querySnapshotUn = await _users.where('username', isEqualTo: user).get();

    List<UserData> ret = [];

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

  Future<UserData> getUser(String userId) async {
    var doc = await _users.doc(userId).get();
    var data = doc.data() as Map<String, dynamic>;

    String id = data["id"];
    String userName = data["username"];
    String email = data["email"];
    String profilePicUrl = data["profileUrl"];

    return UserData.fresh(
        id: id,
        userName: userName,
        email: email,
        profilePicUrl: profilePicUrl,
    );

  }

}