import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download


ReceivePort sftpStartServer(SSHClient client){
  ReceivePort mainThreadRecivePort = ReceivePort();
  Isolate.spawn(sftpSetup, mainThreadRecivePort.sendPort);
  
  return ReceivePort();
}

void sftpSetup(SendPort mainThreadSendPort){
  //should setup server operations


}


void mainThreadlistenClient(ReceivePort mainThreadRecivePort){
//for local file operations
//must have upload and tell sftp function to upload it 
}
void mainThreadlistenServer(ReceivePort mainThreadRecivePort){
//server file operations
//must have download
//must tell sftp to download a file
}
