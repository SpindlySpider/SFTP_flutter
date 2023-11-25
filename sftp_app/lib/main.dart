import 'package:flutter/material.dart';
import 'package:sftp_app/my_bindings.dart';
import 'text_entry_field.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "ssh.dart";


Pointer ssh_sesh = nullptr;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<LandingPage> createState() => _LandingPageState();
}


class _LandingPageState extends State<LandingPage> {
  String hostname = "";
  int port = 22;
  String status_message = "";
  CustomInputField hostnameInput = CustomInputField(labelText: "hostname",showPassword:true ,icon: Icon(Icons.wifi_tethering_sharp),controller_: TextEditingController(),);
  CustomInputField portInput =CustomInputField(labelText: "port",showPassword:true ,icon: Icon(Icons.tag),controller_: TextEditingController());
        


  @override
  Widget build(BuildContext context) {
    String log="";
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
          ElevatedButton(onPressed: (){
            Pointer<Utf8> error_message = "".toNativeUtf8();
                 hostname = hostnameInput.getText();
                 port = int.parse(portInput.getText());
            setState(() {
                 print("$hostname $port");
                //  main_ssh(hostname, port,ssh_sesh);
                 Pointer ssh_sesh = init_ssh();
                 if (ssh_sesh == null){
                  status_message = "not initilized";
                 }
                set_connection_info(hostname, port, ssh_sesh, error_message);
                status_message = error_message.toDartString();
            }
            );

            int host = verify_host(ssh_sesh,error_message);
            print("debug1");
            setState(() {
            status_message = error_message.toDartString();
              
            });
            if(host<0){
              if (host == -2){
                //run pop up code here
                // this is yes to the unknown hosts need to add y/n funcitonality
                sSH_KNOWN_HOSTS_UNKOWN_handle(ssh_sesh, error_message);
            setState(() {
              
                status_message = error_message.toDartString();
            });
              }
              else{
                status_message = error_message.toDartString();
            setState(() {
                status_message = status_message + ", ending session";
            });
                my_ssh_disconnect(ssh_sesh);
                my_ssh_free(ssh_sesh);
              }
            }

          try_password_authentication(ssh_sesh, "RjHRL4v8",error_message);
          status_message = error_message.toDartString();
          status_message = "SUCCESS";
          calloc.free(error_message);
            setState(() {
              
            });
            
          }, child: Text("connect")),

          Text(status_message)
        ],
      ),
    );
  }
}
