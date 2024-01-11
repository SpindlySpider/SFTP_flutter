import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:sftp_app/error_popup.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sftp_app/sftp_page.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'package:stream_channel/isolate_channel.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var db = Hive.box("session");
  @override
  Color textColor = Color.fromARGB(255, 255, 159, 28);
  Color appBarColor = Color.fromARGB(255, 1, 22, 39);
  Color backgroundColor = Color.fromARGB(255, 63, 23, 43);
  Color primary1 = Color.fromARGB(255, 124, 23, 46);
  Color primary2 = Color.fromARGB(255, 60, 16, 122);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          "sftp app",
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
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
              icon: Icon(Icons.add_circle_outline_rounded,color: textColor,))
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Expanded(
                child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: db.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: ElevatedButton(
                      onPressed: () async {
                        ReceivePort sshRecievePort = ReceivePort();
                        ReceivePort sftpRecievePort = ReceivePort();
                        String hostname = db.getAt(index)[0];
                        int port = db.getAt(index)[1];
                        String username = db.getAt(index)[2];
                        String? password = db.getAt(index)[3];
                        try {
                          ReceivePort handleReceivePort = ReceivePort();
                          IsolateChannel sshisolateChannel =
                              IsolateChannel.connectReceive(handleReceivePort);

                          Isolate sshIsolate = await Isolate.spawn(ssh_main, [
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
                                  "SSH");
                            }
                            if (message[0] == "error") {
                              print(message);
                              popupDialoge(
                                  context, "${message[1]}", "ssh error");
                            }
                            if (message[0] == "success") {
                              // start sftp
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SftpPage(
                                  mainThreadRecivePort: sshRecievePort,
                                  sftpReciveport: sftpRecievePort,
                                );
                              })).then((value) {
                                sshisolateChannel.sink.add("kill");
                                sshIsolate.kill();
                              });
                            }
                          });
                        } catch (e) {
                          popupDialoge(context, "$e", "ssh error");
                        }
                      },
                      child: Text("connect", style:TextStyle(color: textColor),),
                      style: ElevatedButton.styleFrom(
                        primary: primary1
                      ),
                      
                    ),
                    title: Text(
                        "${db.getAt(index)[0]} :${db.getAt(index)[1]} @${db.getAt(index)[2]} ",
                        style: TextStyle(color: textColor)),
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
              separatorBuilder: (context, index) => Divider(color: textColor,),
            )),
          ],
        ),
      ),
    );
  }
}
