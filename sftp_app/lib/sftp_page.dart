//this should have two sides, local view and server view
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:sftp_app/error_popup.dart';
import 'package:sftp_app/local-io.dart';
import 'package:sftp_app/sftp.dart';

import 'package:stream_channel/isolate_channel.dart';
import 'package:path/path.dart';

class SftpPage extends StatefulWidget {
  SftpPage({
    super.key,
    required this.mainThreadRecivePort,
    required this.sftpReciveport,
  });
  final ReceivePort mainThreadRecivePort;
  final ReceivePort sftpReciveport;

  // SftpPage({super.key,required this.sshSesh});
  // needs to have isolate channel to send messages. make isolate channel
  // pass in path
  @override
  State<SftpPage> createState() => SftpPageState();
}

class SftpPageState extends State<SftpPage> {
    Color textColor = Color.fromARGB(255, 197, 115, 255);
  Color appBarColor = Color.fromARGB(255, 42, 42, 42);
  Color backgroundColor = Color.fromARGB(255, 22, 22, 22);
  Color primary1 = Color.fromARGB(255, 74, 74, 74);
  Color primary2 = Color.fromARGB(255, 60, 16, 122);
  Color clientColor = Color.fromARGB(255, 22, 22, 22);
  Color serverColor = Color.fromARGB(255, 22, 22, 22);
  bool selectOverMultiplePages =
      false; // change this if you want to download/ upload over multiple pages.

  ReceivePort localFileRecivePort = ReceivePort();
  String serverPath = "/";
  String localPath = Directory.current.path;
  late List serverfileList = [];
  late int serverNumOfFiles = 0;
  late int serverNumOfFolders = 0;

  late List selectedSeverItems = [];
  late List selectedLocalItems = [];

  late List localfileList = [];
  late int localNumOfFiles = 0;
  late int localNumOfFolders = 0;

  // ignore: prefer_typing_uninitialized_variables
  late Isolate clientIsolate;
  late IsolateChannel localIsolate;
  late IsolateChannel sftpChannel;
  @override
  void initState() {
    super.initState();
    sftpChannel = IsolateChannel.connectReceive(widget.sftpReciveport);
    localIsolate = IsolateChannel.connectReceive(localFileRecivePort);
    sftpChannel.sink.add(["sftp", "listdir", serverPath]);
    sftpChannel.stream.listen((message) async {
      if (message[0] == "sftp") {
        if (message[1] == "listdir") {
          //should be the directory
          if (!selectOverMultiplePages) {
            selectedSeverItems = [];
          }
          serverfileList = message[2];
          serverNumOfFiles = 0;
          serverfileList[0].remove(".");
          serverfileList[0].remove("..");
          serverfileList[0].insert(0, "..");

          message[2][0].forEach((element) {
            if (element == "") {}
            serverNumOfFiles++;
            serverNumOfFolders++;
            //use this to see how many folders there are
          });
          message[2][1].forEach((element) {
            serverNumOfFiles++;
          });
          serverPath = message[3];
          setState(() {});
          // print(numOfFiles);
        } else if (message[1] == "selected") {
          if (message[2] is String) {
            String filename = message[2];

            if (selectedSeverItems.contains(filename)) {
              setState(() {
                selectedSeverItems.remove(filename);
              });
            } else {
              setState(() {
                selectedSeverItems.add(filename);
              });
            }
            print("here $selectedSeverItems");
          }
        } else if (message[1] == "delete") {
          setState(() {
            if (message[2] == "success") {
              sftpChannel.sink.add(["sftp", "listdir", serverPath]);
              popupDialoge(this.context,
                  "sucessfully deleted : ${basename(message[3])}", "delete");
            } else {
              popupDialoge(this.context,
                  "failed to deleted : ${basename(message[3])}", "delete");
            }
          });
        } else if (message[1] == "download") {
          setState(() {
            if (message[2] == "success") {
              localIsolate.sink.add(["file", "listdir", localPath]);

              popupDialoge(this.context,
                  "sucessfully download : ${basename(message[3])}", "download");
            } else {
              popupDialoge(this.context,
                  "failed to download : ${basename(message[3])}", "download");
            }
          });
        } else if (message[1] == "upload") {
          if (message[2] == "success") {
            sftpChannel.sink.add(["sftp", "listdir", serverPath]);

            popupDialoge(this.context,
                "sucessfully uploaded : ${basename(message[3])}", "upload");
          } else {
            popupDialoge(this.context,
                "failed to upload : ${basename(message[3])}", "upload");
          }
          setState(() {});
        }
      }
      if (message[0] == "error") {
        await popupDialoge(this.context, message[1], "sftp error")
            .then((value) {
          setState(() {
            // serverErrorOccured = true;
            serverPath = dirname(serverPath);
          });
          sftpChannel.sink.add(["sftp", "listdir", serverPath]);
        });
      }
    });

    Isolate.spawn(local_main, [localFileRecivePort.sendPort]).then((value) {
      clientIsolate = value;
    });

    localIsolate.sink.add(["file", "listdir", localPath]);

    localIsolate.stream.listen((message) async {
      print(message);
      if (message[0] == "file") {
        if (message[1] == "listdir") {
          if (!selectOverMultiplePages) {
            selectedLocalItems = [];
          }
          //should be the directory
          localfileList = message[2];
          localNumOfFiles = 0;
          // localfileList[0].remove(".");
          // localfileList[0].remove("..");
          localfileList[0].insert(0, "..");

          message[2][0].forEach((element) {
            if (element == "") {}
            localNumOfFiles++;
            localNumOfFolders++;
            //use this to see how many folders there are
          });
          message[2][1].forEach((element) {
            localNumOfFiles++;
          });
          localPath = message[3];
          setState(() {});
          // print(numOfFiles);
        } else if (message[1] == "selected") {
          if (message[2] is String) {
            String filename = message[2];

            if (selectedLocalItems.contains(filename)) {
              setState(() {
                selectedLocalItems.remove(filename);
              });
            } else {
              setState(() {
                selectedLocalItems.add(filename);
              });
            }
            print("here $selectedLocalItems");
          }
        } else if (message[1] == "delete") {
          setState(() {
            if (message[2] == "success") {
              localIsolate.sink.add(["file", "listdir", localPath]);
              selectedSeverItems = [];
              popupDialoge(this.context,
                  "sucessfully deleted : ${basename(message[3])}", "delete");
            } else {
              popupDialoge(this.context,
                  "failed to deleted : ${basename(message[3])}", "delete");
            }
          });
        }
      } else if (message[0] == "error") {}
    });
    // Isolate.spawn(sftpSetup, [mainThreadRecivePort.sendPort,widget.sshSesh]);
    //this is handling all of the display of the isolates.
  }
  

  Widget build(BuildContext context) {
    //some how put serverpath here ?
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Text("sftp app",
          style: TextStyle(color: textColor)),
          leading: IconButton(
              onPressed: () {
                //must tell isolates to close
                clientIsolate.kill();
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: textColor,)
              ,),
          actions: [
            IconButton(
                onPressed: () async {
                  print("download");
                  if (selectedSeverItems.length > 0) {
                    for (String item in selectedSeverItems) {
                      "$serverPath/$item"; // change to join for local one
                      print((item));
                      sftpChannel.sink.add([
                        "sftp",
                        "download",
                        "file",
                        "$serverPath/$item",
                        "$localPath/$item"
                      ]);
                    }
                  } else {
                    popupDialoge(
                        context,
                        "there are no items to download - try pressing the tick box next to files",
                        "download error");
                  }
                },
                icon: Icon(Icons.download,color: textColor,)),
            IconButton(
                onPressed: () {
                  print("upload");
                  if (selectedLocalItems.length > 0) {
                    for (String item in selectedLocalItems) {
                      String uploadLocalPath = join(localPath, item);
                      String uploadSeverPath = "$serverPath/$item";
                      print((item));
                      print([uploadLocalPath, uploadSeverPath]);
                      sftpChannel.sink.add([
                        "sftp",
                        "upload",
                        "file",
                        uploadLocalPath,
                        uploadSeverPath
                      ]);
                    }
                  } else {
                    popupDialoge(
                        context,
                        "there are no items to upload - try pressing the tick box next to files",
                        "upload error");
                  }
                  print("upload");
                },
                icon: Icon(Icons.upload,color: textColor)),
            IconButton(
                onPressed: () async {
                  print("delete");
                  popupDialogeGetText(context,
                          "are you sure you want to delete(Y/N)", "delete")
                      .then((value) {
                    if (value!.toUpperCase() == "Y") {
                      if (selectedLocalItems.length < 0 &&
                          selectedSeverItems.length < 0) {
                        popupDialoge(
                            context,
                            "there are no items to delete - try pressing the tick box next to files",
                            "delete error");
                      }
                      if (selectedLocalItems.length > 0) {
                        for (String item in selectedLocalItems) {
                          String localFilePath = join(localPath, item);
                          localIsolate.sink
                              .add(["file", "delete", "file", localFilePath]);
                        }
                      }
                      if (selectedSeverItems.length > 0) {
                        for (String item in selectedSeverItems) {
                          sftpChannel.sink.add(
                              ["sftp", "delete", "file", "$serverPath/$item"]);
                        }
                      }
                    }
                  });
                },
                icon: Icon(Icons.delete,color: textColor))
          ],
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            Container serverfileViewContainer = fileView(
                context,
                constraints,
                serverNumOfFiles,
                serverNumOfFiles,
                serverfileList,
                sftpChannel,
                serverPath,
                true,
                serverColor,
                selectedSeverItems);

            Container localfileViewContainer = fileView(
                context,
                constraints,
                localNumOfFiles,
                localNumOfFolders,
                localfileList,
                localIsolate,
                localPath,
                false,
                clientColor,
                selectedLocalItems);
            return Column(
              children: [
                Expanded(
                  child: serverfileViewContainer,
                ),
                Divider(
                  color: textColor,
                  height: 5,
                  thickness: 5,
                ),
                Expanded(child: localfileViewContainer)
              ],
            );
          },
        ));
  }
}
