import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "my_bindings.dart";

void main(){

}

void main_ssh(String hostname, int port){
  Pointer ssh_sesh = init_ssh();
  if (ssh_sesh == null){
    print("ERROORORRORO");
  }
  ssh_set_connection_info(ssh_sesh, hostname.toNativeUtf8(), port);
  String error_message = try_ssh_connect_server(ssh_sesh);
  print(error_message);
  verify_host(ssh_sesh);
  error_message = try_password_authentication(ssh_sesh, "RjHRL4v7");
  print(error_message);
  print("finished");
  my_ssh_disconnect(ssh_sesh);
  my_ssh_free(ssh_sesh);
}