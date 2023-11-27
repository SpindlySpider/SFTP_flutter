import 'package:flutter/material.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'text_entry_field.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "dart:isolate";

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}


class _LandingPageState extends State<LandingPage> {
  String hostname = "";
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
            setState(() {
              
            });
            hostname = hostnameInput.getText();
            port = int.parse(portInput.getText());
            ReceivePort mainReceivePort = ReceivePort();
            late Isolate ssh_initilize;
            late SendPort sshSendPort;
            await Isolate.spawn(isolate_ssh_initilize,mainReceivePort.sendPort).then((value){
              ssh_initilize = value;
            });
            
              
            mainReceivePort.listen((message) {
              print(message);
              if (message is SendPort){
                sshSendPort = message;
            sshSendPort.send(["set_connection_info",hostname,port]);
              }
              else if( message[0] == "error"){
                if(message[1]=="connect successful"){

                  sshSendPort.send(["verify_host"]);
                }
                else if (message[1] == "exit"){
                  //try to kill process before crash
                  ssh_initilize.kill(priority: Isolate.immediate);
                }
                else{
                print(message[1]);
                setState(() {
                status_message = message[1];
                  
                });
                }
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
