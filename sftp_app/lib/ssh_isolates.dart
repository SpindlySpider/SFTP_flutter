import 'dart:convert';
import 'package:flutter/material.dart';
import "error_popup.dart";
import 'package:dartssh2/dartssh2.dart';


//NOTE this has two parts a handle section and a isolates section
//handles should be called on main thread and handle success/error messages
//isoltes functions should only be called in a ssh isolate

Future<List> ssh_setup_initlize(String hostname, int port,
    String username, var password) async {
      // this should not be called in main islate
  try {

    var client = SSHClient(
      await SSHSocket.connect(hostname, port),
      username: username,
      onPasswordRequest: () async {
        //this is what will happen if pass word is not null
        return password;
      }
      //TODO need to setup, a password verification box
      //TODO need to setup on change of host key
      //TODO workout how to make it come up with a error if it does not propperly connect
      
    );
    return ["success",client];

  } catch (e) {
    return ["error","$e"];
    // popupDialoge(buildContext, "$e", "ssh error");
  }
}

Future<List> ssh_setup(String hostname, int port, String username,
    BuildContext buildContext, String? password) async {
  //TODO make setup not a isolate
  //TODO there is a timeout duration it should be set in setting read from database
  try {
    if (password == "") {
      password = await popupDialogeGetText(
          buildContext, "please enter the remote host password", "SSH");


          
      var client = await ssh_setup_initlize(
              hostname, port, username, buildContext, password)
          .then((value) async {
            if(value[0] == "success"){
              SSHClient sshClient = value[1];
        var uptime = await sshClient.run('uptime');
        print(utf8.decode(uptime as List<int>));

            }
      });
      return ["success",client];
    } 
    else {
      var client = await ssh_setup_initlize(
          hostname, port, username, password).then((sshClient) async{
                    var uptime = await sshClient.run('uptime');
        print(utf8.decode(uptime as List<int>));
          });
          return ["success",client];
      // return client;

    }
  } catch (e) {
    // popupDialoge(buildContext, "$e", "ssh error");
    return ["error","$e"];
  }
}

// functions to handle the ssh session.

Future<String> ssh_setup_initlize_handle(List<String> response, BuildContext buildContext) async {
  if(response[0] == "success"){
    return "success";
  }
  else{
    return response[1];
  }

  //this must be called within the ssh setup function
}

Future<List> ssh_setup_handle(String response,
    BuildContext buildContext) async {
  //TODO make setup not a isolate
  //TODO there is a timeout duration it should be set in setting read from database
  try {
    if (password == "") {
      password = await popupDialogeGetText(
          buildContext, "please enter the remote host password", "SSH");


          
      var client = await ssh_setup_initlize(
              hostname, port, username, buildContext, password)
          .then((value) async {
            if(value[0] == "success"){
              SSHClient sshClient = value[1];
        var uptime = await sshClient.run('uptime');
        print(utf8.decode(uptime as List<int>));

            }
      });
      return ["success",client];
    } 
    else {
      var client = await ssh_setup_initlize(
          hostname, port, username, buildContext, password).then((sshClient) async{
                    var uptime = await sshClient?.run('uptime');
        print(utf8.decode(uptime as List<int>));
          });
          return ["success",client];
      // return client;

    }
  } catch (e) {
    // popupDialoge(buildContext, "$e", "ssh error");
    return ["error","$e"];
  }
}