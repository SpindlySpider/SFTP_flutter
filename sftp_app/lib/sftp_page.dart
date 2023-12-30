//this should have two sides, local view and server view
import 'dart:io';
import 'dart:isolate';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:sftp_app/error_popup.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sftp_app/local-io.dart';
import 'package:sftp_app/sftp.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'package:sqflite/sqflite.dart';
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

  var localIsolate;
  var sftpChannel;
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
        } else if(message[1]=="delete"){
          setState(() {
            if(message[2]=="success"){
            sftpChannel.sink.add(["sftp", "listdir", serverPath]);
            popupDialoge(this.context, "sucessfully deleted : ${basename(message[3])}", "delete");
            }
            else{
              popupDialoge(this.context, "failed to deleted : ${basename(message[3])}", "delete");
            }
          });
        }
        
        else if (message[0] == "error") {
          await popupDialoge(this.context, message[1], "sftp error")
              .then((value) {
            setState(() {
              // serverErrorOccured = true;
              serverPath = dirname(serverPath);
            });
            sftpChannel.sink.add(["sftp", "listdir", serverPath]);
          });
        }
      }
    });

    Isolate.spawn(local_main, [localFileRecivePort.sendPort]);

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
          backgroundColor: Color.fromARGB(255, 93, 33, 132),
          title: Text("sftp app"),
          leading: Text("$serverPath"),
          actions: [
            IconButton(onPressed: () async{
              print("download");
              if(selectedSeverItems.length>0){
                for(String item in selectedSeverItems){
                  "$serverPath/$item"; // change to join for local one
                  print((item));
              sftpChannel.sink.add(["sftp","download","file","$serverPath/$item","$localPath/$item"]);
                }
              }
              else{
                popupDialoge(context, "there are no items to download - try pressing the tick box next to files", "download error");
              }
            }, icon: Icon(Icons.download)),
            IconButton(onPressed: (){
              print("upload");
              if(selectedLocalItems.length>0){
                for(String item in selectedLocalItems){
                  String uploadLocalPath = join(localPath,item);
                  String uploadSeverPath = "$serverPath/$item";
                  print((item));
                  print([uploadLocalPath,uploadSeverPath]);
              sftpChannel.sink.add(["sftp","upload","file",uploadLocalPath,uploadSeverPath]);
                }
              }
              else{
                popupDialoge(context, "there are no items to upload - try pressing the tick box next to files", "upload error");
              }
print("upload");

            }, icon: Icon(Icons.upload)),
            IconButton(onPressed: (){
              print("delete");
              if(selectedLocalItems.length<0&&selectedSeverItems.length<0){
popupDialoge(context, "there are no items to delete - try pressing the tick box next to files", "delete error");
              }
              if(selectedLocalItems.length>0){
                for(String item in selectedLocalItems){
                  String localFilePath = join(localPath,item);
              sftpChannel.sink.add(["file","delete","file",localFilePath]);
                }
                }
              if(selectedSeverItems.length>0){
                for(String item in selectedSeverItems){
              sftpChannel.sink.add(["sftp","delete","file","$serverPath/$item"]);
                }
              }

            }, icon: Icon(Icons.delete))
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
                Colors.grey,
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
                const Color.fromARGB(255, 65, 61, 61),
                selectedLocalItems);
            return Column(
              children: [
                Expanded(
                  child: serverfileViewContainer,
                ),
                Divider(
                  color: Colors.black,
                  height: 5,
                ),
                Expanded(child: localfileViewContainer)
              ],
            );
          },
        ));
  }
}
