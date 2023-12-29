import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:sftp_app/sftp.dart';
import 'package:stream_channel/isolate_channel.dart';
import "error_popup.dart";
import 'package:dartssh2/dartssh2.dart';

//NOTE this has two parts a handle section and a isolates section
//handles should be called on main thread and handle success/error messages
//isoltes functions should only be called in a ssh isolate
void ssh_main(List args) async {
  SendPort sendPort = args[0];
  String hostname = args[1];
  int port = args[2];
  String username = args[3];
  String? password = args[4];
  SendPort sftpSendPort = args[5];

  IsolateChannel isolateChannel = IsolateChannel.connectSend(sendPort);
  IsolateChannel sftpChannel = IsolateChannel.connectSend(sftpSendPort);

  // have a isolate channel for ssh and one for sftp
  //maybe one for io too
  // isolateChannel.stream.listen((message) {
  //   print("recived message on isolate");

  // });

  List? result =
      await ssh_setup([isolateChannel, hostname, port, username, password]);
  if (result![0] == "success") {
    //need to sort this to handle sftp operations, need to asign ssh client
    print("sucessful");
    sftpSetup(result[1], sftpChannel);

  } else {
    // handle error stuff.
    print("error");
  }
}

Future<List> ssh_setup_initlize(
    String hostname, int port, String username, var password) async {
  // this should not be called in main islate
  try {
    var client = SSHClient(await SSHSocket.connect(hostname, port),
        username: username, onPasswordRequest: () async {
      //this is what will happen if pass word is not null
      return password;
    });
    return ["success", client];
  } catch (e) {
    return ["error", "$e"];
    // popupDialoge(buildContext, "$e", "ssh error");
  }
}

Future<List?> ssh_setup(List args) async {
  //this function interfaces withn main isolate
  IsolateChannel isolateChannel = args[0];

  List errormsg = ["error", ""]; //used when ssh is not correctly initilised
  try {
    String hostname = args[1];
    int port = args[2];
    String username = args[3];
    String? password = args[4];

    var client;
    if (password == "") {
      isolateChannel.sink.add(["null_password"]);
      isolateChannel.stream.listen((message) async {
        if (message[0] == "password") {
          client =
              await ssh_setup_initlize(hostname, port, username, message[1])
                  .then((value) async {
            if (value[0] == "success") {
              SSHClient sshClient = value[1];
              var uptime = await sshClient.run('uptime');
              print(utf8.decode(uptime as List<int>));
              isolateChannel.sink.add(["success"]);
              return ["success", sshClient];
            } else {
              return value; // string of ["error",error message]
            }
          });
        } else {
          isolateChannel.sink.add(errormsg);
        }
      });
    } else {
      var client = await ssh_setup_initlize(hostname, port, username, password)
          .then((value) async {
        if (value[0] == "success") {
          SSHClient sshClient = value[1];
          var uptime = await sshClient.run('uptime');
          print(utf8.decode(uptime as List<int>));
          isolateChannel.sink.add(["success"]);
          return ["success", sshClient];
        } else {
          isolateChannel.sink.add(errormsg);
          return errormsg;
        }
      });
      if (client[0] == "success") {
        return client;
      }
    }
    // return client;
  } catch (e) {
    isolateChannel.sink.add(["error", "$e"]);
    return ["error", "$e"];
  }
}

// functions to handle the ssh session. must be called on main isolate
//vvvvv

void ssh_main_handle(
    String hostname,
    int port,
    String username,
    BuildContext buildContext,
    var password,
    ReceivePort handleReceivePort,
    IsolateChannel isolateChannel,
    ReceivePort sftpReceivePort,
    IsolateChannel sftpReciveport) async {
  //might be useful to return a recive and send port? can use it later on then.
  ReceivePort handleReceivePort = ReceivePort();
  IsolateChannel isolateChannel =
      IsolateChannel.connectReceive(handleReceivePort);

  Isolate.spawn(ssh_main, [
    handleReceivePort.sendPort,
    hostname,
    port,
    username,
    password,
    sftpReceivePort.sendPort
  ]);
  isolateChannel.stream.listen((message) async {
    if (message[0] == "null_password") {
      password = await popupDialogeGetText(
              buildContext, "please enter the remote host password", "SSH")
          .then((value) {
        // isolateSendPort.send(["password", password]);
      });
    }
    if (message[0] == "error") {
      popupDialoge(buildContext, "${message[1]}", "ssh error");
    }
    if (message[0] == "success") {
      // start sftp
      sftp_main_handle();
    }
  });

  //this must be called within the ssh setup function
}
