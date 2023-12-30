import 'dart:ffi';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:sftp_app/sftp_server.dart';
import 'package:stream_channel/isolate_channel.dart';
import "package:path/path.dart";

//need two main functions
//one for server with send port
//one for client machine to upload download

List fileView(BuildContext context, BoxConstraints constraints, int numOfFiles,
    int numOfFolders, List fileList, IsolateChannel sftpChannel) {
  //maybe return list so you can reassign server path
  //[container,filepath]
  var serverPath;
  Container container = Container(
    height: constraints.maxHeight / 2,
    color: Colors.amber,
    alignment: Alignment.topCenter,
    child: ListView.separated(
      // scrollDirection: Axis.vertical,
      itemCount: numOfFiles,
      itemBuilder: (context, index) {
        numOfFolders = fileList[0].length;
        int fileIndex;
        String leadchar = "";
        if (numOfFolders > index) {
          leadchar = "#";
          fileIndex = 0;
        } else {
          fileIndex = 1;
          index = index - numOfFolders;
        }
        return ListTile(
          title: Text("$leadchar${fileList[fileIndex][index]}"),
          onTap: () {
            var localPath = serverPath;
            print(serverPath);
            if (fileIndex == 0) {
              if (fileList[fileIndex][index] == "..") {
                localPath = dirname(serverPath);
              } else {
                localPath = join(serverPath, fileList[fileIndex][index]);
                localPath = "$serverPath/${fileList[fileIndex][index]}";
              }
              serverPath = localPath;
              print(localPath);
              sftpChannel.sink.add(["sftp", "listdir", localPath]);
            }
          },
          // title: Text("5"),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    ),
  );
  return [container,serverPath];
}

void sftp_main_handle() {}

//backend isolate vvv

void sftpSetup(
    SSHClient sshClient, IsolateChannel sftpChannel, SftpClient sftp) async {
  //entry is sendPort, sshclient
  //need error handling
  sftpChannel.stream.listen((event) async {
    try {
      if (event[0] == "sftp") {
        if (event[1] == "listdir") {
          //["sftp","listdir","dirpath"]
          //can send list of lists where first part is folders, second is files
          var sftpItems = await sftp.listdir(event[2]);
          List items = [[], []]; // [[folders],[files]]
          for (SftpName file in sftpItems) {
            if (file.attr.isFile) {
              items[1].add(file.filename);
            } else {
              items[0].add(file.filename);
            }
          }

          sftpChannel.sink.add(
              ["sftp", "listdir", items]); // may cause errors since sftp type
        }
      }
    } catch (e) {
      sftpChannel.sink.add(["error", "$e"]);
    }
  });
}
