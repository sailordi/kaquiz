import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import '../adapter/firebaseAdapter.dart';
import 'responses.dart';

class Invites {

  static Future<Response> sendInvite(Request request, String userId) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    await FirebaseAdapter.sendInvite(userData.$1,userId);

    return Response.ok('Invitation sent successfully');
  }

  static Future<Response> getInvites(Request request,String userId) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    (Map<String,dynamic>,Map<String,dynamic>) data = await FirebaseAdapter.getInvites(userData.$1);

    return Response.ok(jsonEncode({
      'incoming': data.$1,
      'outgoing': data.$2,
    }), headers: {'Content-Type': 'application/json'});

  }

  static Future<Response> declineInvite(Request request, String userId) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    await FirebaseAdapter.declineInvite(userId,userData.$1);
    
    return Response.ok('Invitation declined successfully');
  }

  static Future<Response> acceptInvite(Request request, String userId) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    await FirebaseAdapter.acceptInvite(userId,userData.$1);

    return Response.ok('Invitation accepted successfully');
  }

}

final invitesRouter = Router()
  ..post('/<user_id>', Invites.sendInvite)
  ..get('/<user_id>', Invites.getInvites)
  ..post('/<user_id>/decline', Invites.declineInvite)
  ..post('/<user_id>/accept', Invites.acceptInvite);