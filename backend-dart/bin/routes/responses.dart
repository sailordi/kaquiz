import 'dart:convert';

import 'package:shelf/shelf.dart';

Response badRequest(String err) {
    return Response.badRequest(
    body: jsonEncode({'error': err}),
      headers: {'Content-Type': 'application/json'});
}

Response forbidden(String err) {
  return Response.forbidden(
      jsonEncode({'error': err}),
      headers: {'Content-Type': 'application/json'});
}

Response serverError(String err) {
  return Response.internalServerError(
      body:jsonEncode({'error': err}),
      headers: {'Content-Type': 'application/json'});
}

Response error(int code,String err) {
  switch(code) {
    case 400: return badRequest(err);
    case 401: return forbidden(err);
    default: return serverError(err);
  }
}