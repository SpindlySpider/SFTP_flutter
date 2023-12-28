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
}
