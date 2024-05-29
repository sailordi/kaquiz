import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../adapter/firebaseAdapter.dart';
import 'responses.dart';

class Users {

 static Future<Response> userUpdate(Request request)  async{
  final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
     return error(userData.$2,userData.$1);
    }

    final payload = jsonDecode(await request.readAsString());
    final profilePic = payload['avatar'];
    final userName = payload['name'];

    final user = await FirebaseAdapter.updateUser(userData.$1,userName,profilePic);

   return Response.ok(jsonEncode(user), headers: {'Content-Type': 'application/json'});
 }

}

final usersRouter = Router()..put('/',Users.userUpdate);