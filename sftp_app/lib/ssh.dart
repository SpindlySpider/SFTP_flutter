import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import "my_bindings.dart";
import 'dart:developer';
import 'package:logger/logger.dart';
void main(){

}



void set_connection_info(String hostname, int port, Pointer ssh_sesh,Pointer<Utf8> error_message){;
  ssh_set_connection_info(ssh_sesh, hostname.toNativeUtf8(), port);
  try_ssh_connect_server(ssh_sesh,error_message);
  log(error_message.toDartString());
}




void main_ssh(String hostname, int port, Pointer ssh_sesh){
  ssh_sesh = init_ssh();
  Pointer<Utf8> error_message = calloc.allocate<Utf8>(500);
  if (ssh_sesh == null){
    exit(-1);
  }


  set_connection_info(hostname, port, ssh_sesh, error_message);

  // ssh_set_connection_info(ssh_sesh, hostname.toNativeUtf8(), port);
  // error_message = try_ssh_connect_server(ssh_sesh).toNativeUtf8();
  // log(error_message.toDartString());
  // error_message = "".toNativeUtf8();
  int host = verify_host(ssh_sesh,error_message); 
  log(error_message.toDartString());
  if(host<0){
    if (host == -2){
      //run pop up code here
      // this is yes to the unknown hosts need to add y/n funcitonality
      //buffer overflow
      sSH_KNOWN_HOSTS_UNKOWN_handle(ssh_sesh, error_message);
      log(error_message.toDartString());
    }
    else{
      log("host1");
      log(error_message.toDartString());
      my_ssh_disconnect(ssh_sesh);
      my_ssh_free(ssh_sesh);
    }
  }

  try_password_authentication(ssh_sesh, "RjHRL4v8",error_message);
  log(error_message.toDartString());
  log("finished");
  calloc.free(error_message);
  //ssh_exit(ssh_sesh);
  //just use the ssh free to exit program
  // malloc.free(ssh_sesh);
}

void exit_ssh(Pointer ssh_sesh){
  my_ssh_disconnect(ssh_sesh);
  my_ssh_free(ssh_sesh);

}