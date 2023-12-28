import 'dart:ffi';
import 'dart:isolate';
import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:sftp_app/sftp_server.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download

void sftpSetup(List obj) async {
  //entry is sendPort, sshclient
  final socket = await SSHSocket.connect('35.195.113.47', 22);
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
  mainThreadSendPort.send(thisRevicePort.sendPort);


  ReceivePort isolateReciveports = ReceivePort();
  //i recon is the ssh thing, i guess stoer ssh in a hive box and access later
  // SSHClient sshClient = obj[1];
  thisRevicePort.listen((message) async {
    if (message[0] == "setup") {
      SSHClient sshClient = client;
      SendPort isolateSendport;
      var isolate = await Isolate.spawn(listdir, isolateReciveports.sendPort);
      // Isolate.spawn(listdir,[isolateReciveport.sendPort,sshClient,"/"])
      isolateReciveports.listen((message) async {
        if (message is SendPort) {
          // isolate.ping(thisRevicePort.sendPort);
          // message.send([sshClient, "/"]);
          SftpClient sftp = await sshClient.sftp();
          message.send([sftp, "/"]);
          print("sent isolate");
          message.send("strt");
        } else {
          print("somthing");
          print(message);
          isolate.kill();
        }

      }
      )
      ;

      // ["setup",dirpath,]
      //get list of current working directory
      //TODO change temp to obj[1]

      // clientThreadSendPort
    }
    if (message[0] == "listdir") {}
    //invoke commands here such as download client get cwd all that
  });
}
