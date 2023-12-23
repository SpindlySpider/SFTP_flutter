import 'package:flutter/material.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class HomePage extends StatefulWidget {
  HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  @override
  var db;

  Widget build(BuildContext context) {
    db = Hive.box("session");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 93, 33, 132),
        title: Text("sftp app"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: 
          
          ListView(
            
            children:<Widget> [
              if(db.isNotEmpty)
                for(List entry in db.values )
                ListTile(
                  title: Center(child: Text(entry[0])),
                  trailing: Icon(Icons.more_vert),
                ),

              
              
    Container(
      height: 50,
      color: Colors.amber[600],
      child: const Center(child: Text('Entry A'))),

              
            ],
          )
          
          ),
          
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LandingPage())).then((value){
                                setState(() {
                                  
                                });
                              });
                });
              },
              child: Text("add ssh"))
        ],
      ),
    );
  }
}
