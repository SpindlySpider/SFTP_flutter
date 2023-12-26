import 'dart:ffi';
import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download

Future<ReceivePort> sftpStartServer(SSHClient client) async {
  ReceivePort mainThreadRecivePort = ReceivePort();
  Isolate.spawn(sftpSetup, mainThreadRecivePort.sendPort);
  SftpClient sftp = await client.sftp();
  return mainThreadRecivePort;
}

void sftpSetup(SendPort mainThreadSendPort) {
  //should setup server operations
  //serpate threads for server and client operations
  late SendPort clientThreadSendPort;
  SendPort serverThreadSendPort;
  ReceivePort serverReceivePort = ReceivePort();
  ReceivePort clientReceivePort = ReceivePort();
  Isolate.spawn(mainThreadlistenClient, clientReceivePort.sendPort);
  Isolate.spawn(mainThreadlistenServer, serverReceivePort.sendPort);
  clientReceivePort.listen((message) async {
    if (message is SendPort) {
      clientThreadSendPort = message;
      +.send(message)
    }
  });
  serverReceivePort.listen((message) {
    if (message is SendPort) {
      serverThreadSendPort = message;
    }
  });
}

void mainThreadlistenClient(SendPort mainThreadSendPort) {
  ReceivePort clientReceivePort = ReceivePort();
  mainThreadSendPort.send(clientReceivePort.sendPort);
  clientReceivePort.listen((message) async {
    if (message[0] == "") {

    }

  });
//for local file operations
//must have upload and tell sftp function to upload it
}

void mainThreadlistenServer(SendPort mainThreadSendPort) {
  ReceivePort serverReceivePort = ReceivePort();
  mainThreadSendPort.send(serverReceivePort.sendPort);
  serverReceivePort.listen((message) async {
    if (message[0] == "") {

    }
  });
//
//server file operations
//must have download
//must tell sftp to download a file
}
