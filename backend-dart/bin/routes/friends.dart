import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../adapter/firebaseAdapter.dart';
import 'responses.dart';

class Friends {

  static Future<Response> deleteFriend(Request request, String id) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    await FirebaseAdapter.deleteFriend(userData.$1,id);

    return Response.ok('Friend deleted successfully');
  }

  static Future<Response> getFriendsLocations(Request request) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    List<String> data = await FirebaseAdapter.friendLocations(userData.$1);

    return Response.ok(jsonEncode(data),headers: {'Content-Type': 'application/json'});
  }
  
}

final friendsRouter = Router()
  ..delete('/<id>',Friends.deleteFriend)
  ..get('/',Friends.getFriendsLocations);