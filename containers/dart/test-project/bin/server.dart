/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import 'dart:io';

Future main() async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );

  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    request.response
      ..write('Hello remote world!')
      ..close();
  }
}
