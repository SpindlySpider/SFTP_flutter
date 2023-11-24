import 'package:flutter/material.dart';
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
            setState(() {
                 hostname = hostnameInput.getText();
                 port = int.parse(portInput.getText());
                 print("$hostname $port");
                 main_ssh(hostname, port,ssh_sesh);
              
            });
          }, child: Text("connect")),

          Text(log)
        ],
      ),
    );
  }
}
