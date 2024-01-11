import 'dart:isolate';



void listdir(SendPort sendport) async {
  ReceivePort receivePort = ReceivePort();
  sendport.send(receivePort.sendPort);
  
  receivePort.listen((message) async {
    if(message !="start"){
    print("listing dir:");
    print(message[0]);
    print("ssh client");
    String dirpath = message[1];
    print("path");

    var sftp = message[0];

    print("sftp");
    List items = await sftp.listdir(dirpath);
    print(items);
    sendport.send(items);
    sftp.close();


    }

    else{

    }
  
    // receivePort.close();
  });
}
