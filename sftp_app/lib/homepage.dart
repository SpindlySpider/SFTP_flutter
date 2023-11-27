import 'package:flutter/material.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'text_entry_field.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "dart:isolate";

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}


class HomePageState extends State<HomePage> {
  GlobalKey<LandingPageState> landingPageKeys = GlobalKey<LandingPageState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 93, 33, 132),
        title: Text("sftp app"), centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            setState(() {
            landingPageKeys.currentState?.dispose();
            landingPageKeys = GlobalKey<LandingPageState>();
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => LandingPage(key: landingPageKeys)));
              
            });
          }, child: Text("ssh"))

        ],
      ),
    );
  }
}
