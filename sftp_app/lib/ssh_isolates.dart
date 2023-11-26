
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import "my_bindings.dart";
import "ssh.dart";

void isolate_ssh_initilize(SendPort sendPort){
  Pointer ssh = "".toNativeUtf8();
  ReceivePort receivePort = ReceivePort();
  Pointer ssh_sesh =init_ssh();
  Pointer<Utf8> error_message = calloc.allocate<Utf8>(250) ;

  set_connection_info(hostname, port, ssh_sesh, error_message);
            int host; 
            status_message = error_message.toDartString();
            print(error_message.toDartString());
            error_message = "".toNativeUtf8();
            host = verify_host(ssh_sesh,error_message);

            status_message = error_message.toDartString();
            print(error_message.toDartString());

            print(host);
            if(host<0){
              if (host == -2){
                //run pop up code here
                // this is yes to the unknown hosts need to add y/n funcitonality
                sSH_KNOWN_HOSTS_UNKOWN_handle(ssh_sesh, error_message);
                print(error_message.toDartString());
                status_message = error_message.toDartString();
                //if user wants to accept use host = 0
                host = 0;
                }

            else{
              print(error_message.toDartString());
              setState(() {
                status_message = error_message.toDartString() + ",ending session";
                
              });
            //give popup to quit 
                // my_ssh_disconnect(ssh_sesh);
                // my_ssh_free(ssh_sesh);
                // ssh_sesh = nullptr;
                // calloc.free(error_message);

              }
            }
            if (host != 0){
                // my_ssh_disconnect(ssh_sesh);
                // my_ssh_free(ssh_sesh);
                // ssh_sesh = nullptr;
                // calloc.free(error_message);
              //exit
            }
            else{

          try_password_authentication(ssh_sesh, "RjHRL4v8",error_message);
          status_message = error_message.toDartString();
          status_message = "SUCCESS";              
          calloc.free(error_message);
            }




}