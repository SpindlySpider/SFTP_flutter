//this should have two sides, local view and server view
import 'dart:isolate';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:sftp_app/error_popup.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sftp_app/sftp.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:path/path.dart';

class SftpPage extends StatefulWidget {
  SftpPage({
    super.key,
    required this.mainThreadRecivePort,
    required this.sftpReciveport,
  });
  ReceivePort mainThreadRecivePort;
  ReceivePort sftpReciveport;

  // SftpPage({super.key,required this.sshSesh});
  // needs to have isolate channel to send messages. make isolate channel
  // pass in path
  @override
  State<SftpPage> createState() => SftpPageState();
}

class SftpPageState extends State<SftpPage> {
  String serverPath = "/";

  late List fileList = [];
  late int numOfFiles = 0;
  late int numOfFolders = 0;
  bool serverErrorOccured = false;
  var isolateChannel;
  var sftpChannel;
  @override
  void initState() {
    super.initState();
    isolateChannel = IsolateChannel.connectReceive(widget.mainThreadRecivePort);
    sftpChannel = IsolateChannel.connectReceive(widget.sftpReciveport);

    sftpChannel.sink.add(["sftp", "listdir", serverPath]);

    sftpChannel.stream.listen((message) async {
      if (message[0] == "sftp") {
        if (message[1] == "listdir") {
          //should be the directory
          fileList = message[2];
          numOfFiles = 0;
          fileList[0].remove(".");
          fileList[0].remove("..");
          fileList[0].insert(0, "..");

          message[2][0].forEach((element) {
            if (element == "") {}
            numOfFiles++;
            numOfFolders++;
            //use this to see how many folders there are
          });
          message[2][1].forEach((element) {
            numOfFiles++;
          });
            serverPath = message[3];
          setState(() {
          });
          print(numOfFiles);
        }
      } else if (message[0] == "error") {
        await popupDialoge(this.context, message[1], "sftp error").then((value){
        setState(() {
          // serverErrorOccured = true;
          serverPath = dirname(serverPath);
        });
        sftpChannel.sink.add(["sftp", "listdir", serverPath]);

        });
      }
    });

    // Isolate.spawn(sftpSetup, [mainThreadRecivePort.sendPort,widget.sshSesh]);
    //this is handling all of the display of the isolates.
  }

  Widget build(BuildContext context) {
    //some how put serverpath here ?
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 93, 33, 132),
          title: Text("sftp app"),
          leading: Text("$serverPath"),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            List fileViewList = fileView(context, constraints, numOfFiles,
                numOfFolders, fileList, sftpChannel, serverPath);
            Container fileViewContainer = fileViewList[0];
            print(serverPath);
            if (serverErrorOccured) {
              print("error");
              serverErrorOccured = false;
            } else {}

            return Column(
              children: [
                Expanded(
                  child: fileViewContainer,
                ),
                Divider(
                  color: Colors.black,
                  height: 5,
                ),
                Expanded(
                    child: Container(
                  height: constraints.maxHeight / 2,
                  color: const Color.fromARGB(255, 77, 74, 67),
                  alignment: Alignment.bottomCenter,
                )),
              ],
            );
          },
        ));
  }
}
