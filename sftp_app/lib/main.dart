import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import "landing_page.dart";
import 'homepage.dart';
import "sftp_page.dart";
void main() async{
    await Hive.initFlutter();
    var box = await Hive.openBox('session');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // home: HomePage(),
      home: SftpPage()
    );
  }
}
