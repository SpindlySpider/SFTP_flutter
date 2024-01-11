import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'homepage.dart';
void main() async{
    await Hive.initFlutter();
    // ignore: unused_local_variable
    var box = await Hive.openBox('session');
  runApp( const MyApp());
  // runApp( MyApp(sshClient: client));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // const MyApp({super.key,required this.sshClient});
  // final SSHClient sshClient;
  // This widget is the root of your application.
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      
  debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomePage(),
      // home: SftpPage(sshSesh:sshClient)
      // home: SftpPage()
    );
  }
}
