import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'text_entry_field.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "error_popup.dart";
import "";

class LandingPage extends StatefulWidget {
  LandingPage(
      {super.key, this.hostname, this.username, this.password, this.port});
  String? hostname;
  String? username;
  String? password;
  int? port;
  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  String hostname = "";
  String username = "";
  var password = "";
  int port = 22;
  CustomInputField hostnameInput = CustomInputField(
    labelText: "hostname",
    showPassword: true,
    icon: Icon(Icons.wifi_tethering_sharp),
    controller_: TextEditingController(),
    showEye: false,
    
  );
  CustomInputField portInput = CustomInputField(
    labelText: "port",
    showPassword: true,
    icon: Icon(Icons.tag),
    controller_: TextEditingController(),
    showEye: false,
  );
  CustomInputField usernameInput = CustomInputField(
    labelText: "username",
    showPassword: true,
    icon: Icon(Icons.tag),
    controller_: TextEditingController(),
    showEye: false,
  );
  CustomInputField passwordInput = CustomInputField(
    labelText: "password",
    showPassword: false,
    icon: Icon(Icons.tag),
    controller_: TextEditingController(),
    showEye: true,
  );

  late Pointer ssh_sesh;
  Pointer<Utf8> error_message = calloc.allocate<Utf8>(250);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 21, 20, 22),
        title: Text("sftp app"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: hostnameInput,
                flex: 2,
              ),
              SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: portInput,
                flex: 1,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: usernameInput,
                flex: 1,
              ),
              SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: passwordInput,
                flex: 1,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
              onPressed: () {
                // verify if host name and port are vaild
                if (widget.hostname == null) {
                  hostname = hostnameInput.getText();
                } else {
                  hostname = widget.hostname!;
                }
                if (widget.username == null) {
                  username = usernameInput.getText();
                } else {
                  username = widget.username!;
                }
                if (widget.password == null) {
                  username = passwordInput.getText();
                } else {
                  password = widget.password!;
                }
                if (widget.port == null) {
                  port = int.parse(portInput.getText());
                } else {
                  port = widget.port!;
                }

                if (!(hostname == "" && username == "")) {
                  setState(() {
                    try {
                      //using hostname as key
                      var box = Hive.box('session');
                      box.add([hostname,port, username, password]);
                      Navigator.pop(context);
                      // var sshClient = ssh_setup(
                      //     hostname, port, username, context, password);

                      // should pass the ssh session to the isol);
                    } catch (e) {
                      popupDialoge(context, "$e", "ssh error");
                    }
                  });
                }
              },
              child: Text("save")),
        ],
      ),
    );
  }
}
