import 'dart:io';
import 'dart:isolate';
import "package:path/path.dart";
import 'package:stream_channel/isolate_channel.dart';




// backend vvv


void local_main(List args)async{
    SendPort sendPort = args[0];
    IsolateChannel isolateChannel = IsolateChannel.connectSend(sendPort);

    isolateChannel.stream.listen((event) async {
      print("event"); 
      if(event[0]=="file"){
        if(event[1]=="listdir"){
          String localPath = event[2];
          print(localPath);
          Directory dir = Directory(localPath);
          List items = await dir.list().toList();
          List files = [[],[]];
          for(FileSystemEntity file in items){
            FileStat stat = await file.stat();
            if(stat.type == FileSystemEntityType.file){
              String filename =basename(file.path);
              files[1].add(filename);
            }
            else{
              String foldername =basename(file.path);
              files[0].add(foldername);
            }
          }
          isolateChannel.sink.add(["file","listdir",files,localPath]);
        }
        else if(event[1]=="selected"){
          String filename = event[2];
          isolateChannel.sink.add(["file","selected",filename]);
        }
      }
    });
}