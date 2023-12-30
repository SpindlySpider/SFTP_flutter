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
    required this.hostname,
    required this.port,
    required this.username,
    required this.password,
    
  });
  ReceivePort mainThreadRecivePort;
  ReceivePort sftpReciveport;
  String hostname;
  int port;
  String username;
  String? password;


  // SftpPage({super.key,required this.sshSesh});
  // needs to have isolate channel to send messages. make isolate channel
  // pass in path
  @override
  State<SftpPage> createState() => SftpPageState();
}

class SftpPageState extends State<SftpPage> { 
  String serverPath = "/";


  late List fileList =[];
  late int numOfFiles=0;
  late int numOfFolders=0;
  var isolateChannel;
  var sftpChannel;
  @override
  void initState() {
super.initState();
    isolateChannel =IsolateChannel.connectReceive(widget.mainThreadRecivePort);
    sftpChannel= IsolateChannel.connectReceive(widget.sftpReciveport);
  
    ssh_main_handle("34.140.186.12", 22, "up2107487", this.context, "RjHRL4v8",
        widget.mainThreadRecivePort, isolateChannel, widget.sftpReciveport, sftpChannel);

    sftpChannel.sink.add(["sftp", "listdir", "/"]);

    sftpChannel.stream.listen((message) async {

      if (message[0] == "sftp") {
        if (message[1] == "listdir") {
          //should be the directory
          print(message[2]);
          fileList = message[2];
          numOfFiles = 0;
          fileList[0].remove(".");
          fileList[0].remove("..");
          fileList[0].insert(0, "..");
          message[2][0].forEach((element) {
            if(element == ""){}
            numOfFiles++;
            numOfFolders++;
            //use this to see how many folders there are
           });
          message[2][1].forEach((element) {
            numOfFiles++;
           });
           setState(() {
             
           });
           print(numOfFiles);
           
        }
      }
      else if(message[0] =="error"){
        popupDialoge(this.context, message[1], "sftp error");
        serverPath = dirname(serverPath);
      }
    }
    );


    // Isolate.spawn(sftpSetup, [mainThreadRecivePort.sendPort,widget.sshSesh]);
    //this is handling all of the display of the isolates.
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 93, 33, 132),
          title: Text("sftp app"),
          leading: Text("$serverPath"),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                    child: Container(
                  height: constraints.maxHeight / 2,
                  color: Colors.amber,
                  alignment: Alignment.topCenter,
                  child: ListView.separated(
                    // scrollDirection: Axis.vertical,
                    itemCount: numOfFiles,
                    itemBuilder: (context, index) {
                      numOfFolders = fileList[0].length;
                      int fileIndex;
                      String leadchar="";
                      if(numOfFolders>index){
                        leadchar = "#";
                        fileIndex=0;

                      }
                      else{
                        fileIndex =1;
                        index= index-numOfFolders;
                      }
                      return ListTile(
                        title: Text("$leadchar${fileList[fileIndex][index]}"),
                        onTap: (){
                          var localPath = serverPath;
                          print(serverPath);
                          if(fileIndex==0){
                            if(fileList[fileIndex][index]==".."){
                              localPath =dirname(serverPath);
                            }
                            else{
                            localPath = join(serverPath,fileList[fileIndex][index]);
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
                )),
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
