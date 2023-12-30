import 'dart:io';
import 'dart:isolate';
import "package:path/path.dart";
import 'package:stream_channel/isolate_channel.dart';




// backend vvv


void local_main(List args)async{
    SendPort sendPort = args[0];
    IsolateChannel isolateChannel = IsolateChannel.connectSend(sendPort);
    isolateChannel.stream.listen((event) async { 
      if(event[0]=="file"){
        if(event[1]=="listdir"){
          String localPath = event[2];
          Directory dir = Directory(localPath);
          List items = await dir.list().toList();
          List files = [[],[]];
          for(FileSystemEntity file in items){
            FileStat stat = await file.stat();
            if(stat.type == FileSystemEntityType.file){
              String filename =basename(file.path);
              print(filename);
              files[1].add(filename);
            }
            else{
              String foldername =basename(file.path);
              print("#$foldername");
              files[0].add(foldername);
            }
          }
          isolateChannel.sink.add(["file","listdir",files,localPath]);
        }
      }
    });
}