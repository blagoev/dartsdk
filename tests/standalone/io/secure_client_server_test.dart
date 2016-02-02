// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// VMOptions=
// VMOptions=--short_socket_read
// VMOptions=--short_socket_write
// VMOptions=--short_socket_read --short_socket_write

import "dart:async";
import "dart:io";

import "package:async_helper/async_helper.dart";
import "package:expect/expect.dart";

InternetAddress HOST;

String localFile(path) => Platform.script.resolve(path).toFilePath();
List<int> readLocalFile(path) => (new File(localFile(path))).readAsBytesSync();

SecurityContext serverContext = new SecurityContext()
  ..useCertificateChainBytes(readLocalFile('certificates/server_chain.pem'))
  ..usePrivateKeyBytes(readLocalFile('certificates/server_key.pem'),
                         password: 'dartdart');

SecurityContext clientContext = new SecurityContext()
  ..setTrustedCertificates(file: localFile('certificates/trusted_certs.pem'));


Future<SecureServerSocket> startEchoServer() {
  return SecureServerSocket.bind(HOST,
                                 0,
                                 serverContext).then((server) {
    server.listen((SecureSocket client) {
      client.fold(<int>[], (message, data) => message..addAll(data))
          .then((message) {
            client.add(message);
            client.close();
          });
    });
    return server;
  });
}

Future testClient(server) {
  return SecureSocket.connect(HOST, server.port, context: clientContext)
  .then((socket) {
    socket.write("Hello server.");
    socket.close();
    return socket.fold(<int>[], (message, data) => message..addAll(data))
        .then((message) {
          Expect.listEquals("Hello server.".codeUnits, message);
          return server;
        });
  });
}

void main() {
  asyncStart();
  InternetAddress.lookup("localhost").then((hosts) => HOST = hosts.first )
      .then((_) => startEchoServer())
      .then(testClient)
      .then((server) => server.close())
      .then((_) => asyncEnd());
}
