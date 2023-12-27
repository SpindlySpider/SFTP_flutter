import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import "landing_page.dart";
import 'homepage.dart';
import "sftp_page.dart";
void main() async{
    await Hive.initFlutter();
    var box = await Hive.openBox('session');
    final socket = await SSHSocket.connect('localhost', 22);
  final client = SSHClient(
    socket,
    username: 'root',
    onPasswordRequest: () {
      return "";
    },
  );
  runApp( MyApp(sshClient: client));
}

class MyApp extends StatelessWidget {
  // const MyApp({super.key})
  const MyApp({super.key,required this.sshClient});
  final SSHClient sshClient;
  // This widget is the root of your application.
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // home: HomePage(),
      home: SftpPage(sshSesh:sshClient)
    );
  }
}
