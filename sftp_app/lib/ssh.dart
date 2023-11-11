import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "my_bindings.dart";

void main(){

}

void main_ssh(String hostname, int port){
  Pointer ssh_sesh = init_ssh();
  ssh_set_connection_info(ssh_sesh, hostname.toNativeUtf8(), port);
  String error_message = try_ssh_connect_server(ssh_sesh);
  print(error_message);

}