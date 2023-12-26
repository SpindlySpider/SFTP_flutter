import 'dart:ffi';
import 'dart:isolate';
import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download



void sftpSetup(SendPort mainThreadSendPort) {
  //should setup server operations
  //serpate threads for server and client operations
  //need 3 things, server communcation, client communication , parent isolate communiation.
  ReceivePort thisRevicePort = ReceivePort();

  SendPort clientThreadSendPort;
  SendPort serverThreadSendPort;
  ReceivePort serverReceivePort = ReceivePort();
  ReceivePort clientReceivePort = ReceivePort();
  mainThreadSendPort.send(thisRevicePort);
  thisRevicePort.listen((message) {
    //invoke commands here such as download client get cwd all that

  });

  Isolate.spawn(mainThreadlistenServer, serverReceivePort.sendPort);
  clientReceivePort.listen((message) async {
    if (message is SendPort) {
      clientThreadSendPort = message;
    }
  });


  Isolate.spawn(mainThreadlistenClient, clientReceivePort.sendPort);
  serverReceivePort.listen((message)async {
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
