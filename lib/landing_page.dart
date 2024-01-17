import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'text_entry_field.dart';
import "error_popup.dart";

class LandingPage extends StatefulWidget {
  LandingPage(
      {super.key,
      required this.hostname,
      required this.username,
      required this.password,
      required this.port,
      this.boxIndex});
  final String hostname;
  final String username;
  final String password;
  final int port;
  final int? boxIndex;
  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  Color textColor = Color.fromARGB(255, 197, 115, 255);
  Color buttonColor = Color.fromARGB(255, 74, 74, 74);
  Color appBarColor = Color.fromARGB(255, 42, 42, 42);
  Color backgroundColor = Color.fromARGB(255, 22, 22, 22);
  Color primary1 = Color.fromARGB(255, 74, 74, 74);
  Color primary2 = Color.fromARGB(255, 60, 16, 122);
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

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    hostname = widget.hostname;
    port = widget.port;
    username = widget.username;
    password = widget.password;

    hostnameInput.setDefaultText(hostname);
    portInput.setDefaultText("$port");
    usernameInput.setDefaultText(username);
    passwordInput.setDefaultText(password);

    super.initState();
  }

  String hostname = "";
  int port = 22;
  String username = "";
  String password = "";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: appBarColor,
          title: Text(
            "sftp app",
            style: TextStyle(color: textColor),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: textColor,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: hostnameInput,
                  flex: 2,
                ),
                VerticalDivider(color: textColor, thickness: 2),
                Expanded(
                  child: portInput,
                  flex: 1,
                ),
              ],
            ),
            Divider(color: textColor),
            usernameInput,
            passwordInput,
            Divider(color: textColor),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:buttonColor 
              ),
              onPressed: () {
                // verify if host name and port are vaild

                if (hostnameInput.getText() != "") {
                  hostname = hostnameInput.getText();
                } else if (widget.hostname != "") {
                  hostname = hostnameInput.getText();
                }
                if (hostnameInput.getText() != "") {
                  username = usernameInput.getText();
                } else if (widget.username != "") {
                  username = widget.username;
                }
                if (passwordInput.getText() != "") {
                  password = passwordInput.getText();
                } else if (widget.password != "") {
                  password = widget.password;
                }

                if (portInput.getText() != "") {
                  try {
                    port = int.parse(portInput.getText());
                  } catch (e) {
                    popupDialoge(context, "$e", "password error");
                  }
                } else if (widget.port != 22) {
                  try {
                    port = int.parse(portInput.getText());
                  } catch (e) {
                    popupDialoge(context, "$e", "password error");
                  }
                }
                if (!(hostname == "" && username == "")) {
                  setState(() {
                    try {
                      //using hostname as key
                      var box = Hive.box('session');
                      if (widget.boxIndex != null) {
                        box.putAt(widget.boxIndex!,
                            [hostname, port, username, password]);
                      } else {
                        box.add([hostname, port, username, password]);
                      }

                      print("$hostname $username");
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
              child: Text("save", style: TextStyle(color: textColor)),
            )
          ],
        ),
      ),
    );
  }
}
