import 'dart:io';

import 'package:args/args.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'routes/auth.dart';
import 'routes/users.dart';
import 'routes/locations.dart';
import 'routes/invites.dart';
import 'routes/friends.dart';

void main(List<String> args) async {
  FirebaseDart.setup();
  var parser = ArgParser()..addOption('port', abbr: 'p')..addOption('host',abbr: 'h');
  
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var host = result['host'] ?? Platform.environment['HOST'] ?? '0.0.0.0';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  final app = Router()
    ..mount('/api/auth',authRouter.call)
    ..mount('/api/users', usersRouter.call)
    ..mount('/api/locations', locationsRouter.call)
    ..mount('/api/invites', invitesRouter.call)
    /*..mount('/api/friends', friendsRouter)*/;

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(app.call);

  var server = await io.serve(handler, host, port);
  print('Serving at http://${server.address.host}:${server.port}');

}
