import 'package:dartssh2/dartssh2.dart';
import 'package:sftp_app/sftp.dart';
import 'package:sftp_app/ssh_isolates.dart';

Future<List> listdir(SSHClient sshClient, String dirpath) async{
  var sftp = await sshClient.sftp();
  List items = await sftp.listdir(dirpath);
  sftp.close();
  return items;
}