import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../adapter/firebaseAdapter.dart';
import 'responses.dart';

class Authentication {

  static Future<Response> authenticateUser(Request request) async {
    var token = await FirebaseAdapter.verifyRequest(request);
    
    if(token.$2 != 200) {
      return error(token.$2,token.$1);
    }

    return Response.ok(jsonEncode({'access_token': token.$1}));
  }

}

final authRouter = Router()..post('/',Authentication.authenticateUser);