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

Container fileView(BuildContext context, BoxConstraints constraints, int numOfFiles,
    int numOfFolders, List fileList, IsolateChannel channel, String initPath, bool server , Color colour, List selectedItems) {
  //maybe return list so you can reassign server path
  //[container,filepath]
  var path = initPath;
  Container container = Container(
    height: constraints.maxHeight / 2,
    color: colour,
    alignment: Alignment.topCenter,
    child: ListView.separated(
      // scrollDirection: Axis.vertical,
      itemCount: numOfFiles,
      itemBuilder: (context, index) {
        bool checked;
        bool folder;
        numOfFolders = fileList[0].length;
        if( !(numOfFolders > index) ){
          if(selectedItems.contains(fileList[1][index-numOfFolders])){
          checked = true;
          }
          else{
            checked = false;
          }
        }
        else{
        checked = false;

        }
        int fileIndex;
        String leadchar = "";
        if (numOfFolders > index) {
          leadchar = "#";
          fileIndex = 0;
          folder = true;
          
        } else {
          fileIndex = 1;
          index = index - numOfFolders;
          folder = false;
        }
        if(server){
        return listTileFilesSFTP(
          leadchar,
          fileList,
          fileIndex,
          index,
          path,
          channel, checked, folder
        );
        }
        else{
        return listTileFilesLocal(
          leadchar,
          fileList,
          fileIndex,
          index,
          path,
          channel,checked,folder
        );

        }
      },
      separatorBuilder: (context, index) => const Divider(),
    ),
  );
  return container;
}

ListTile listTileFilesSFTP(var leadchar,List fileList,int fileIndex,int index, String serverPath, IsolateChannel sftpChannel,bool checked,bool folder){
return ListTile(
  trailing: !folder?Checkbox(
    value:checked,
    onChanged: (bool? value){
      checked = !checked;
      sftpChannel.sink.add(["sftp","selected",fileList[fileIndex][index]]);
    },
  ):null
  ,
          title: Text("$leadchar${fileList[fileIndex][index]}"),
          onTap: () {
            var localPath = serverPath;
            if (fileIndex == 0) {
              if (fileList[fileIndex][index] == "..") {
                localPath = dirname(serverPath);
              } 
              else {
                if(serverPath == "/"){
                localPath = "/${fileList[fileIndex][index]}";
                }
                else{
                localPath = "$serverPath/${fileList[fileIndex][index]}";
                }
                // localPath = join(serverPath, fileList[fileIndex][index]);
              }
              serverPath = localPath;
              sftpChannel.sink.add(["sftp", "listdir", serverPath]);
            }
          },
          // title: Text("5"),
        );

}
ListTile listTileFilesLocal(var leadchar,List fileList,int fileIndex,int index, String clientPath, IsolateChannel localChannel,bool checked,bool folder ){
return ListTile(
  trailing: !folder?Checkbox(
    value:checked,
    onChanged: (bool? value){
      checked = !checked;
      localChannel.sink.add(["file","selected",fileList[fileIndex][index]]);
    },
  ):null
  ,
          title: Text("$leadchar${fileList[fileIndex][index]}"),
          onTap: () {
            var localPath = clientPath;
            if (fileIndex == 0) {
              if (fileList[fileIndex][index] == "..") {
                localPath = dirname(clientPath);
              } 
              else {
                if(localPath == rootPrefix(localPath)){
                  localPath =join(localPath,fileList[fileIndex][index]);
                }
                else{
                localPath = join(localPath,fileList[fileIndex][index]);
                }
                // localPath = join(serverPath, fileList[fileIndex][index]);
              }
              localChannel.sink.add(["file", "listdir", localPath]);
            }
          },
          // title: Text("5"),
        );

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
              ["sftp", "listdir", items,event[2]]); //path["sftp","listdir",items,sftppath]
        }
        else if(event[1]=="selected"){
          String filename = event[2];
          print(filename);
          sftpChannel.sink.add(["sftp","selected",filename]);
        }
      }
      
    
    } catch (e) {
      sftpChannel.sink.add(["error", "$e"]);
    }
  });
}
