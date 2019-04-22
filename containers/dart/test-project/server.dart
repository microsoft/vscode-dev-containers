import 'dart:io';

Future main() async {


  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );
  print('*************************************************************************');
  print('* Press F1, select "Remote-Containers: Forward Port from Container...", *');
  print('* and select the server port listed below to access server.             *');
  print('*************************************************************************');
  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    request.response
      ..write('Hello remote world!')
      ..close();
  }
}