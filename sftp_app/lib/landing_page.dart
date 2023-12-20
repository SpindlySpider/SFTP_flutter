import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'text_entry_field.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "dart:isolate";
import "error_popup.dart";

class LandingPage extends StatefulWidget {
  LandingPage({Key? key}) : super(key: key);
  @override
  State<LandingPage> createState() => LandingPageState();
}


class LandingPageState extends State<LandingPage> {

  String hostname = "";
  String username = "";
  String password = "";
  int port = 22;
  String status_message = "";
  CustomInputField hostnameInput = CustomInputField(labelText: "hostname",showPassword:true ,icon: Icon(Icons.wifi_tethering_sharp),controller_: TextEditingController(),);
  CustomInputField portInput =CustomInputField(labelText: "port",showPassword:true ,icon: Icon(Icons.tag),controller_: TextEditingController());

  late Pointer ssh_sesh ;
Pointer<Utf8> error_message = calloc.allocate<Utf8>(250);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 93, 33, 132),
        title: Text("sftp app"), centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [

              Expanded(child:hostnameInput, flex: 2,),
              SizedBox(width: 16.0,)
              ,
          Expanded(child:portInput,
        flex: 1,)
            ],
          ),
          SizedBox(height: 10.0,),
          ElevatedButton(onPressed: ()async {
            // verify if host name and port are vaild
            setState(() {
              
            });
            hostname = hostnameInput.getText();
            port = int.parse(portInput.getText());
            ReceivePort mainReceivePort = ReceivePort();
            late Isolate ssh_initilize;
            late SendPort sshSendPort;
            late SSHClient sshclient;
            await Isolate.spawn(ssh_setup,mainReceivePort.sendPort).then((value){
              ssh_initilize = value;
            });
            
              
            mainReceivePort.listen((message) {
              if(message is SendPort){
                print(1);
                sshSendPort = message;
                print(2);
                sshSendPort.send(["setup",hostname,port,username,password]);
                print(3);
              }
              else if(message[0] == "setup"){
                sshclient = message[1];
              }
              else if(message[0] == "error"){
                print("error");
                setState(() {
                popupDialoge(context,message[1],"SSH error" );
                  
                });
              }

              });




          }
          , child: Text("connect")),

          Text(status_message)
        ],
      ),
    );
  }
}
