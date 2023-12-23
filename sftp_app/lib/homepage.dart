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
          Expanded(
              child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: db.length,
            itemBuilder: (context, index) {
              return ListTile(
                  leading: ElevatedButton(
                    onPressed: () {},
                    child: Text("connect"),
                  ),
                  title: Text(db.getAt(index)[0]),
                  trailing: PopupMenuButton<ListTileTitleAlignment>(
                    itemBuilder: (context) {
                      void removeEntry(index) {
                        db.deleteAt(index);
                      }

                      return <PopupMenuEntry<ListTileTitleAlignment>>[
                        PopupMenuItem(
                          child: Text("edit"),
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LandingPage(
                                          hostname:db.getAt(index)[0],
                                          port: db.getAt(index)[1],
                                          username: db.getAt(index)[2],
                                          password: db.getAt(index)[3],


                                        )))
                                .then((value) {
                              setState(() {});
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Text("delete"),
                          onTap: () {
                            setState(() {
                              print("delete");
                              removeEntry(index);
                            });
                          },
                        ),
                      ];
                    },
                  ));
            },
            separatorBuilder: (context, index) => Divider(),
          )),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LandingPage())).then((value) {
                    setState(() {});
                  });
                });
              },
              child: Text("add ssh"))
        ],
      ),
    );
  }
}
