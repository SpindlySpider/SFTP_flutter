import 'package:flutter/material.dart';
import 'package:sftp_app/landing_page.dart';
import 'package:sftp_app/ssh_isolates.dart';
import 'text_entry_field.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "dart:isolate";

Future<void> popupDialoge(
    BuildContext context, String errorMsg, String title) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorMsg),
                // Add more widgets as needed.
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Future<String?> popupDialogeGetText(
    // need to use await so you can get the return type of the password
    BuildContext context,
    String description,
    String title) async {
  String password = "";
  CustomInputField passwordInput = CustomInputField(
    labelText: "password",
    showPassword: false,
    icon: Icon(Icons.tag),
    controller_: TextEditingController(),
    showEye: true,
  );
  return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: [
            Column(
              children: [
                Text(description),
                passwordInput,
                ElevatedButton(onPressed: () {
                  password = passwordInput.getText();
                  Navigator.pop(context,password);
                }, child: Text("finish"))
              ],
            )
          ],
        );
      });
}
