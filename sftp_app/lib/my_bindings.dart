// lib/my_bindings.dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
  final dllPath = path.join( 'c', 'mylibary.dll');
final DynamicLibrary myDll = DynamicLibrary.open(dllPath);

typedef Init_ssh_c = Pointer Function();
typedef Init_ssh_dart = Pointer Function();

typedef Ssh_set_connection_info_c = Void Function(Pointer ssh_sesh, Pointer<Utf8> hostname, Int32 port);
typedef Ssh_set_connection_info_dart = void Function(Pointer ssh_sesh, Pointer<Utf8> hostname, int port);

typedef Try_ssh_connect_server_c =  Pointer<Utf8> Function(Pointer ssh_sesh);
typedef Try_ssh_connect_server_dart =  Pointer<Utf8> Function(Pointer ssh_sesh);

typedef Verify_host_c = Int32 Function(Pointer ssh_sesh, Pointer<Utf8> error_message);
typedef Verify_host_dart = int Function(Pointer ssh_sesh, Pointer<Utf8> error_message);
//UTF8 may cause a error because we are using bigger buffers



// this one will probbaly cause a issue since there is no way to input yes or no



typedef Try_password_authentication_c = Void Function(Pointer ssh_sesh, Pointer<Utf8> password,Pointer<Utf8> error_message);
typedef Try_password_authentication_dart = void Function(Pointer ssh_sesh, Pointer<Utf8> password,Pointer<Utf8> error_message);

typedef My_ssh_disconnect_c = Void Function(Pointer ssh_sesh);
typedef My_ssh_disconnect_dart = void Function(Pointer ssh_sesh);

typedef My_ssh_free_c = Void Function(Pointer ssh_sesh);
typedef My_ssh_free_dart = void Function(Pointer ssh_sesh);

typedef SSH_KNOWN_HOSTS_UNKOWN_handle_c = Int32 Function(Pointer ssh_sesh, Pointer<Utf8> error_message); 
typedef SSH_KNOWN_HOSTS_UNKOWN_handle_dart = int Function(Pointer ssh_sesh, Pointer<Utf8> error_message);

typedef Ssh_exit_c = Int32 Function(Pointer ssh_sesh);
typedef Ssh_exit_dart = int Function(Pointer ssh_sesh);

////////


typedef FreebufferC = Void Function(Pointer<Utf8> buffer);
typedef FreebufferDart = void Function(Pointer<Utf8> buffer);


Pointer init_ssh(){
  final Init_ssh_dart initSsh = myDll
  .lookupFunction<Init_ssh_c, Init_ssh_dart>('init_ssh');   
  return initSsh();
}

void ssh_set_connection_info(Pointer ssh_sesh, Pointer<Utf8> hostname, int port){
 final Ssh_set_connection_info_dart set_connection_info = myDll
      .lookupFunction<Ssh_set_connection_info_c, Ssh_set_connection_info_dart>("ssh_set_connection_info");

  set_connection_info(ssh_sesh, hostname, port);
}



String try_ssh_connect_server(Pointer ssh_sesh){
 final Try_ssh_connect_server_dart trySshConnectServer = myDll
      .lookupFunction<Try_ssh_connect_server_c, Try_ssh_connect_server_dart>("try_ssh_connect_server");
      return trySshConnectServer(ssh_sesh).toDartString();
}

int verify_host(Pointer ssh_sesh,Pointer<Utf8> error_message){
  final Verify_host_dart verify_host = myDll
      .lookupFunction<Verify_host_c, Verify_host_dart>("verify_host");
  return verify_host(ssh_sesh,error_message);
}

void try_password_authentication(Pointer ssh_sesh, String password,Pointer<Utf8> error_message){
  final Try_password_authentication_dart password_verifiction = myDll
      .lookupFunction<Try_password_authentication_c, Try_password_authentication_dart>("try_password_authentication");
  password_verifiction(ssh_sesh,password.toNativeUtf8(),error_message);
} 



void my_ssh_disconnect(Pointer ssh_sesh){
  final My_ssh_disconnect_dart ssh_disconnect = myDll
      .lookupFunction<My_ssh_disconnect_c, My_ssh_disconnect_dart>("my_ssh_disconnect");
  ssh_disconnect(ssh_sesh);
}
void my_ssh_free(Pointer ssh_sesh){
  final My_ssh_free_dart ssh_free = myDll
      .lookupFunction<My_ssh_free_c, My_ssh_free_dart>("my_ssh_free");
  ssh_free(ssh_sesh);
}

int sSH_KNOWN_HOSTS_UNKOWN_handle(Pointer ssh_sesh,Pointer<Utf8> error_message){
  // use this function for the known hosts has changed as the "yes" version of the function
  final SSH_KNOWN_HOSTS_UNKOWN_handle_dart ssh_known_hosts_handle = myDll
      .lookupFunction<SSH_KNOWN_HOSTS_UNKOWN_handle_c, SSH_KNOWN_HOSTS_UNKOWN_handle_dart>("SSH_KNOWN_HOSTS_UNKOWN_handle");
  return ssh_known_hosts_handle(ssh_sesh,error_message);
}

int ssh_exit(Pointer ssh_sesh){
   final Ssh_exit_dart ssh_exit_ = myDll
      .lookupFunction<Ssh_exit_c, Ssh_exit_dart>("ssh_exit"); 
    return ssh_exit_(ssh_sesh);
}