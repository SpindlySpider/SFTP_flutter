import 'dart:ffi';
import 'dart:isolate';
import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download

void sftpSetup(List obj) {
  //entry is sendPort, sshclient

  //should setup server operations
  //serpate threads for server and client operations
  //need 3 things, server communcation, client communication , parent isolate communiation.
  ReceivePort thisRevicePort = ReceivePort();
  SendPort mainThreadSendPort = obj[0];
  SSHClient sshClient = obj[1];

  late SendPort clientThreadSendPort;
  late SendPort serverThreadSendPort;
  ReceivePort serverReceivePort = ReceivePort();
  ReceivePort clientReceivePort = ReceivePort();


  Isolate.spawn(mainThreadlistenClient, clientReceivePort.sendPort);
  clientReceivePort.listen((message) async {
    if (message is SendPort) {
      clientThreadSendPort = message;
    }
  });

  Isolate.spawn(mainThreadlistenServer, serverReceivePort.sendPort);
  serverReceivePort.listen((message) async {
    if (message is SendPort) {
      serverThreadSendPort = message;
    }
    else if(message[0]=="listdir"){
      String path = message[1];
      List items = message[2];
      obj[0].send("listdir",path,items);
      //passes up the dir to the main thread
    }
  });
  mainThreadSendPort.send(thisRevicePort.sendPort);
  thisRevicePort.listen((message) async {
    if(message[0]=="setup"){
      // ["setup",dirpath,]
      //get list of current working directory
      //TODO change temp to obj[1]
      serverThreadSendPort.send(["listdir",sshClient,message[1]]);
      // clientThreadSendPort

    }
    if(message[0]=="listdir"){
      serverThreadSendPort.send(["listdir",message[1],message[2]]);
    }
    //invoke commands here such as download client get cwd all that
  }
  );
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
    if(message[0]=="listdir"){
      if(message[2] is String){
        SSHClient sshClient = message[1];
        String dirpath = message[2];
        // should use database for the current cwd of string 
        //[sshclient,dirpath]
      var sftp = await sshClient.sftp();
      var items = await sftp.listdir(dirpath);
      sftp.close(); //might cause issues
      mainThreadSendPort.send(["listdir",dirpath,items]);
      }
      }
  });
//
//server file operations
//must have download
//must tell sftp to download a file
}
