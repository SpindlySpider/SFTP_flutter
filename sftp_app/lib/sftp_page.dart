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

class SftpPage extends StatefulWidget {
  SftpPage({
    super.key,
  });
  // SftpPage({super.key,required this.sshSesh});
  // SSHClient  sshSesh;
  @override
  State<SftpPage> createState() => SftpPageState();
}

class SftpPageState extends State<SftpPage> {
  var db;
  ReceivePort mainThreadRecivePort = ReceivePort();
  late SendPort isolatesSendport;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Isolate.spawn(sftpSetup, [mainThreadRecivePort.sendPort]);

    // Isolate.spawn(sftpSetup, [mainThreadRecivePort.sendPort,widget.sshSesh]);
    //this is handling all of the display of the isolates.
    mainThreadRecivePort.listen((message) async {
      if (message is SendPort) {
        isolatesSendport = message;
        print("setup");
        isolatesSendport.send(["setup"]);
        //inital call for all dir entires
      }
      if (message[0] == "listdir") {
        print(message);
        // message[1][0] is current working dir
        // onwards from index 0 is entries
      }
    });
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
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return ListTile();
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
