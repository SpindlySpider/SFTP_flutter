import 'package:flutter/material.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:sqflite/sqflite.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  //HomePageState.ensureInitialized();
  final database = openDatabase("server.db",
  onCreate: (db,version){
    return db.execute(
      "CREATE TABLE session(session_id INTEGER PRIMARY KEY,hostname VARCHAR(16), port INTEGER, username VARCHAR(50), password VARCHAR(200),user_salt VARCHAR(100), cwd_server VARCHAR(1607),cwd_client VARCHAR(1607) )"
    );
  });
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 93, 33, 132),
        title: Text("sftp app"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LandingPage()));
                });
              },
              child: Text("ssh"))
        ],
      ),
    );
  }
}
