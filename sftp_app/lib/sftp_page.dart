//this should have two sides, local view and server view
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:sftp_app/error_popup.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sftp_app/ssh_isolates.dart';

class SftpPage extends StatefulWidget {
  SftpPage({super.key});
  // SftpPage({super.key,required this.sshSesh});
  // SSHClient  sshSesh;
  @override
  State<SftpPage> createState() => SftpPageState();
}

class SftpPageState extends State<SftpPage> {
  @override
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
                height: constraints.maxHeight/2,
                color: Colors.amber,
                alignment: Alignment.topCenter,
                child: ListView.separated(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    
                  },
                  separatorBuilder: (context, index) =>const Divider(),

                ),
              ) 
              ),
Expanded(
              child: Container(
                height: constraints.maxHeight/2,
                color: const Color.fromARGB(255, 77, 74, 67),
                alignment: Alignment.bottomCenter,
              ) 
              ),


          ],

        );
      },)
    );
  }
}
