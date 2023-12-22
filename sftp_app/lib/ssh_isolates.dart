import 'dart:convert';
import 'package:flutter/material.dart';
import "error_popup.dart";
import 'package:dartssh2/dartssh2.dart';
import 'package:sqflite/sqflite.dart';
//TODO SQL database



Future<SSHClient?> ssh_setup_initlize(String hostname, int port,
    String username, BuildContext buildContext, var password) async {
  try {
    var client = SSHClient(
      await SSHSocket.connect(hostname, port),
      username: username,
      onPasswordRequest: () async {
        //this is what will happen if pass word is not null
        return password;
      }
      //TODO need to setup, a password verification box
      //TODO need to setup on change of host key
      //TODO workout how to make it come up with a error if it does not propperly connect
      ,
    );
    return client;
  } catch (e) {
    popupDialoge(buildContext, "$e", "ssh error");
  }

  //this must be called within the ssh setup function
}

Future<SSHClient?> ssh_setup(String hostname, int port, String username,
    BuildContext buildContext, var password) async {
  //TODO make setup not a isolate
  //TODO there is a timeout duration it should be set in setting read from database
  try {
    if (password == "") {
      password = await popupDialogeGetText(
          buildContext, "please enter the remote host password", "SSH");
      var client = await ssh_setup_initlize(
              hostname, port, username, buildContext, password)
          .then((sshClient) async {
        var uptime = await sshClient?.run('uptime');
        print(utf8.decode(uptime as List<int>));
      });
      return client;
    } else {
      var client = await ssh_setup_initlize(
          hostname, port, username, buildContext, password).then((sshClient) async{
                    var uptime = await sshClient?.run('uptime');
        print(utf8.decode(uptime as List<int>));
          });
      return client;
    }
  } catch (e) {
    popupDialoge(buildContext, "$e", "ssh error");
    return null;
  }
}

// void gfdsfdsfds(SendPort sendport) {
//   String password;
//   ReceivePort ssh_receive_port = ReceivePort();

//   sendport.send(ssh_receive_port.sendPort);

//   ssh_receive_port.listen((message) async {
//     if (message[0] == "setup") {
//       // setup needs hostname, port and username
//       //might need to have error call back
//       //not sure how to handle get password
//       // maybe start the ssh then isolate to handle everything
//       //TODO make isolate handle the ssh connection only communicating with main thread when needed for ui updates
//       try {
//         var client = SSHClient(await SSHSocket.connect(message[1], message[2]),
//             username: message[3], onPasswordRequest: () => message[4]);

//         sendport.send(["setup", client]);
//       } catch (e) {
//         String error = "$e";
//         print(error);
//         sendport.send(["error", error]);
//       }
//     }
//   });
// }
