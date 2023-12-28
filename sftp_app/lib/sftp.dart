import 'dart:ffi';
import 'dart:isolate';
import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download

void sftpSetup(List obj) async {
  //entry is sendPort, sshclient
  final socket = await SSHSocket.connect('34.77.98.69', 22);
  final client = SSHClient(
    socket,
    username: 'up2107487',
    onPasswordRequest: () async {
      return "RjHRL4v8";
    },
  );
  //should setup server operations
  //serpate threads for server and client operations
  //need 3 things, server communcation, client communication , parent isolate communiation.
  ReceivePort thisRevicePort = ReceivePort();
  SendPort mainThreadSendPort = obj[0];
  // SSHClient sshClient = obj[1];
  SSHClient sshClient = client;

  ReceivePort serverReceivePort = ReceivePort();
  ReceivePort clientReceivePort = ReceivePort();



    thisRevicePort.listen((message) async {
      if (message[0] == "setup") {
        // ["setup",dirpath,]
        //get list of current working directory
        //TODO change temp to obj[1]
        print("sent listdir command to server thread");
        serverThreadSendPort!.send(["listdir", sshClient, message[1]]);
        // clientThreadSendPort
      }
      if (message[0] == "listdir") {
        serverThreadSendPort!.send(["listdir", sshClient, message[1]]);
      }
      //invoke commands here such as download client get cwd all that
    });
}



