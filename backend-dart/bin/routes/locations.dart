import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../adapter/firebaseAdapter.dart';
import 'responses.dart';

class Locations {

  static Future<Response> submitLocation(Request request) async {
    final userData = await FirebaseAdapter.verifyHeader(request.headers['authorization']);

    if(userData.$2 != 200) {
      return error(userData.$2,userData.$1);
    }

    final payload = await request.readAsString();
    final data = jsonDecode(payload) as Map<String, dynamic>;

    String latitude = data['latitude'];
    String longitude = data['longitude'];

    FirebaseAdapter.updateLocation(userData.$1,latitude,longitude);

    return Response.ok('Location updated successfully');
  }

}

final locationsRouter = Router()..post('/',Locations.submitLocation);
