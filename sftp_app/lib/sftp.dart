import 'dart:ffi';
import 'dart:isolate';
import 'package:hive/hive.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:sftp_app/sftp_server.dart';
import 'package:stream_channel/isolate_channel.dart';

//need two main functions
//one for server with send port
//one for client machine to upload download


void sftp_main_handle(){

}


//backend isolate vvv



void sftpSetup(SSHClient sshClient, IsolateChannel sftpChannel,SftpClient sftp) async {
  //entry is sendPort, sshclient
  //need error handling
  sftpChannel.stream.listen((event)async { 
    try{

    if(event[0]=="sftp"){

      if(event[1]=="listdir"){
        //["sftp","listdir","dirpath"]
        //can send list of lists where first part is folders, second is files
        var sftpItems = await sftp.listdir(event[2]);
        List items = [[],[]]; // [[folders],[files]]
        for(SftpName file in sftpItems){
          if(file.attr.isFile){
            items[1].add(file.filename);
          }
          else{
            items[0].add(file.filename);
          }
        }
        
        sftpChannel.sink.add(["sftp","listdir",items]); // may cause errors since sftp type 
      }

    }
    }
    catch(e){
      sftpChannel.sink.add(["error","$e"]);
    }
  });
}