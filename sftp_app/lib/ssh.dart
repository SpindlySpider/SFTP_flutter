import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import "my_bindings.dart";

void main(){

}

void main_ssh(String hostname, int port){

  Pointer ssh_sesh = init_ssh();
  Pointer<Utf8> error_message = "".toNativeUtf8(); 
  if (ssh_sesh == null){
    print("ERROORORRORO");
  }
  ssh_set_connection_info(ssh_sesh, hostname.toNativeUtf8(), port);
  error_message = try_ssh_connect_server(ssh_sesh).toNativeUtf8();
  print(error_message.toDartString());
  error_message = "".toNativeUtf8();
  int host = verify_host(ssh_sesh,error_message); 

  if(host<0){
    if (host == -2){
      //run pop up code here
      sSH_KNOWN_HOSTS_UNKOWN_handle(ssh_sesh, error_message);
      print(error_message.toDartString());
    }
    else{
      print(error_message.toDartString());
      my_ssh_disconnect(ssh_sesh);
      my_ssh_free(ssh_sesh);
    }
  }

  error_message = try_password_authentication(ssh_sesh, "RjHRL4v8").toNativeUtf8();
  print(error_message.toDartString());
  print("finished");
  calloc.free(error_message);
  my_ssh_disconnect(ssh_sesh);
  my_ssh_free(ssh_sesh);
}