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

class SftpPage extends StatefulWidget {
  SftpPage({
    super.key,
  });
  // SftpPage({super.key,required this.sshSesh});
  // needs to have isolate channel to send messages. make isolate channel
  @override
  State<SftpPage> createState() => SftpPageState();
}

class SftpPageState extends State<SftpPage> {
  ReceivePort mainThreadRecivePort = ReceivePort();
  ReceivePort sftpReciveport = ReceivePort();
  // late List fileList =[];
  @override
  void initState() {


    IsolateChannel isolateChannel =
        IsolateChannel.connectReceive(mainThreadRecivePort);
    IsolateChannel sftpChannel = IsolateChannel.connectReceive(sftpReciveport);
    ssh_main_handle("34.140.186.12", 22, "up2107487", context, "RjHRL4v8",
        mainThreadRecivePort, isolateChannel, sftpReciveport, sftpChannel);

    sftpChannel.sink.add(["sftp", "listdir", "/"]);

    sftpChannel.stream.listen((message) async {

      if (message[0] == "sftp") {
        if (message[1] == "listdir") {
          //should be the directory
          print(message[2]);
          // fileList = message[2];
          // numOfFiles = 0;
          // message[2][0].forEach((element) {
          //   numOfFiles++;
          //   numOfFolders++;
          //   //use this to see how many folders there are
          //  });
          // message[2][1].forEach((element) {
          //   numOfFiles++;
          //  });
          //  print(numOfFiles);
           
        }
      }
super.initState();
    });

    // Isolate.spawn(sftpSetup, [mainThreadRecivePort.sendPort,widget.sshSesh]);
    //this is handling all of the display of the isolates.
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 93, 33, 132),
          title: Text("sftp app"),
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
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      
                      return ListTile(
                        // title: Text("${fileList[fileIndex][index]}"),
                        title: Text("5"),

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
