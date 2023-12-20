
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import "ssh.dart";
import 'package:dartssh2/dartssh2.dart';

void ssh_setup(SendPort sendport){
  String password;
  ReceivePort ssh_receive_port = ReceivePort();

  sendport.send(ssh_receive_port.sendPort);

  ssh_receive_port.listen((message) async {
    if(message[0] == "setup"){
      // setup needs hostname, port and username
      //might need to have error call back
      //not sure how to handle get password
      // maybe start the ssh then isolate to handle everything
      //TODO make setup not a isolate
      //TODO make isolate handle the ssh connection only communicating with main thread when needed for ui updates
      try{
      var client = SSHClient(
        await SSHSocket.connect(message[1],message[2] ),
        username: message[3],
        onPasswordRequest: () => message[4]
        );

      sendport.send(["setup",client]);

      }
      catch(e){
        String error = "$e";
        print(error);
        sendport.send(["error",error]);
      }
    }
  });


}