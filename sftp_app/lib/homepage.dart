import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:sftp_app/error_popup.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sftp_app/local-io.dart';
import 'package:sftp_app/sftp_page.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'package:stream_channel/isolate_channel.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  var db = Hive.box("session");

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 93, 33, 132),
        title: Text("sftp app"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: db.length,
            itemBuilder: (context, index) {
              return ListTile(
                  leading: ElevatedButton(
                    onPressed: () {
                      ReceivePort sshRecievePort = ReceivePort();
                      ReceivePort sftpRecievePort = ReceivePort();
                      String hostname =db.getAt(index)[0] ;
                      int port = db.getAt(index)[1];
                      String username = db.getAt(index)[2];
                      String? password = db.getAt(index)[3];
                      try {
                        //TODO undo this comment haha
                        //need to authetnicate that can connect then push the server
                        //do ssh here and check result

                        ReceivePort handleReceivePort = ReceivePort();
                        IsolateChannel sshisolateChannel =
                            IsolateChannel.connectReceive(handleReceivePort);


                        Isolate.spawn(ssh_main, [
                          handleReceivePort.sendPort,
                          hostname,
                          port,
                          username,
                          password,
                          sftpRecievePort.sendPort
                        ]);


                        sshisolateChannel.stream.listen((message) async {

                          if (!context.mounted) return; 
                          if (message[0] == "null_password") {
                            print("null password");
                            password = await popupDialogeGetText(
                                    context,
                                    "please enter the remote host password",
                                    "SSH")
                                .then((value) {
                              // isolateSendPort.send(["password", password]);
                            });
                          }
                          if (message[0] == "error") {
                            print(message);
                            popupDialoge(
                                context, "${message[1]}", "ssh error");
                          }
                          if (message[0] == "success") {
                            // start sftp
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SftpPage(
                            mainThreadRecivePort: sshRecievePort,
                            sftpReciveport: sftpRecievePort,
                          );
                        })); 
                          }
                        });

                      } catch (e) {
                        popupDialoge(context, "$e", "ssh error");
                      }
                    },
                    child: Text("connect"),
                  ),
                  title: Text(
                      "${db.getAt(index)[0]} :${db.getAt(index)[1]} @${db.getAt(index)[2]} "),
                  trailing: PopupMenuButton<ListTileTitleAlignment>(
                    itemBuilder: (context) {
                      void removeEntry(index) {
                        db.deleteAt(index);
                      }

                      return <PopupMenuEntry<ListTileTitleAlignment>>[
                        PopupMenuItem(
                          child: Text("edit"),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return LandingPage(
                                hostname: db.getAt(index)[0],
                                port: db.getAt(index)[1],
                                username: db.getAt(index)[2],
                                password: db.getAt(index)[3],
                                boxIndex: index,
                              );
                            })).then((value) {
                              setState(() {});
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Text("delete"),
                          onTap: () {
                            setState(() {
                              print("delete");
                              removeEntry(index);
                            });
                          },
                        ),
                      ];
                    },
                  ));
            },
            separatorBuilder: (context, index) => Divider(),
          )),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LandingPage(
                                hostname: "",
                                password: "",
                                port: 22,
                                username: "",
                              ))).then((value) {
                    setState(() {});
                  });
                });
              },
              child: Text("add ssh"))
        ],
      ),
    );
  }
}
