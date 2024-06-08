import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';

import '../globals.dart';

class FirebaseAdapter {

  static Future<(String,int)> verifyRequest(Request request) async {
    try {
      final payload = await request.readAsString();
      String idToken = (jsonDecode(payload) as Map)['id_token'];

      final response = await http.post(
        Uri.parse(_tokenUrl() ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'postBody': 'id_token=$idToken&providerId=google.com',
          'requestUri': 'http://localhost',
          'returnSecureToken': true
        }),

      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        return (body['idToken'] as String,200);
      } else {
        return ('Invalid ID token',400);
      }

    } catch(e) {
      return (e.toString(),500);
    }

  }

  static Future<(String,int)> verifyHeader(String? authHeader) async {
    if (authHeader == null) {
      return ('Unauthorized request',401);
    }

    try {
      final response = await http.post(
        Uri.parse(_headerUrl() ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': authHeader}),
      );

      if (response.statusCode != 200) {
        return ('Unauthorized request',401);
      }
      final userId = jsonDecode(response.body)['users'][0]['localId'];

      return (userId as String,200);

    } catch(e) {
      return (e.toString(),500);
    }

  }

  static Future updateUser(String userId,String userName,String profilePic) async {
    Map<String,dynamic> data = {"username":userName,"profilePic":profilePic};

    await http.patch(
      Uri.parse('${_usersCollectionUrl()}/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fields': data}),
    );

    final userResponse = await http.get(
      Uri.parse('${_usersCollectionUrl()}/$userId'),
    );

    final userData = jsonDecode(userResponse.body)['fields'];

    return userData;
  }

  static Future updateLocation(String userId,String latitude,String longitude) async {
    Map<String,dynamic> data = {'latitude': latitude, 'longitude': longitude, 'timestamp': DateTime.now().toIso8601String() };

    await http.patch(
      Uri.parse('${_locationCollectionUrl()}/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fields': data}),
    );

  }

  static Future sendInvite(String sender,String receiver) async {

    await http.post(
      Uri.parse(_invitesCollectionUrl() ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fields': {
          'sender': {'stringValue': sender},
          'recipient': {'stringValue': receiver},
          'created_at': {'timestampValue': DateTime.now().toIso8601String()},
        }
      }),
    );

  }

  static Future<(Map<String,dynamic>,Map<String,dynamic>)> getInvites(String userId) async {
    final incomingResponse = await http.get(
      Uri.parse('${_invitesCollectionUrl()}?where=recipient==$userId'),
    );

    final outgoingResponse = await http.get(
      Uri.parse('${_invitesCollectionUrl()}?where=sender==$userId'),
    );

    final incomingInvites = jsonDecode(incomingResponse.body)['documents'];
    final outgoingInvites = jsonDecode(outgoingResponse.body)['documents'];

    return (incomingInvites as Map<String,dynamic>,outgoingInvites as Map<String,dynamic>);
  }

  static Future declineInvite(String sender,String receiver) async {
    final invitesResponse = await http.get(
      Uri.parse('${_invitesCollectionUrl()}?where=sender==$sender&where=recipient==$receiver'),
    );

    final invites = jsonDecode(invitesResponse.body)['documents'];

    for (var invite in invites) {
      await http.delete(Uri.parse(invite['name']));
    }

  }

  static Future acceptInvite(String sender,String receiver) async {
    final invitesResponse = await http.get(
      Uri.parse('${_invitesCollectionUrl()}?where=sender==$sender&where=recipient==$receiver'),
    );

    final invites = jsonDecode(invitesResponse.body)['documents'];

    for (var invite in invites) {
      await http.delete(Uri.parse(invite['name']));
    }

    await http.post(
      Uri.parse(_friendsCollectionUrl(receiver) ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fields': {
          'userId': {'stringValue': sender},
        }
      }),
    );

    await http.post(
      Uri.parse(_friendsCollectionUrl(sender) ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fields': {
          'userId': {'stringValue': receiver},
        }
      }),
    );

  }

  static Future deleteFriend(String userId,String friendId) async {

    final friendsResponse = await http.get(
      Uri.parse('${_friendsCollectionUrl(userId)}?where=userId==$friendId'),
    );

    final friends = jsonDecode(friendsResponse.body)['documents'];

    for (var friend in friends) {
      await http.delete(Uri.parse(friend['name']));
    }

    final otherFriendsResponse = await http.get(
      Uri.parse('${_friendsCollectionUrl(friendId)}?where=userId==$userId'),
    );

    final otherFriends = jsonDecode(otherFriendsResponse.body)['documents'];

    for (var friend in otherFriends) {
      await http.delete(Uri.parse(friend['name']));
    }

  }

  static Future<List<String> > friendLocations(String userId) async {
    final friendsResponse = await http.get(
      Uri.parse(_friendsCollectionUrl(userId) ),
    );

    final friends = jsonDecode(friendsResponse.body)['documents'];

    List<String> locations = [];

    for (var friend in friends) {
      final friendId = friend['fields']['friend_id']['stringValue'];
      final locationResponse = await http.get(
        Uri.parse('${_locationCollectionUrl()}/$friendId'),
      );
      locations.add(jsonDecode(locationResponse.body)['fields']);
    }
    return locations;
  }

  static String _tokenUrl() {
    return "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$apiKey";
  }

  static String _headerUrl() {
    return "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$apiKey";
  }

  static String _usersCollectionUrl() {
    return "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users";
  }

  static String _locationCollectionUrl() {
    return "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/locations";
  }

  static String _invitesCollectionUrl() {
    return "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/invites";
  }

  static String _friendsCollectionUrl(String userId) {
    return "${_usersCollectionUrl()}/$userId/friends";
  }

}
