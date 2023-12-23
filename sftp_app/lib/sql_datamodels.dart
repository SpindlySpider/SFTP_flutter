
class Session {
  final int session_id;
  final String hostname;
  final int port;
  final String username;
  final String password;
  final String user_salt;
  final String cwd_server;
  final String cwd_client;

  const Session({
    required this.session_id,
    required this.hostname,
    required this.port,
    required this.username,
    required this.password,
    required this.user_salt,
    required this.cwd_server,
    required this.cwd_client,
  });
  Map<String, dynamic> toMap() {
    return {
      'session_id': session_id,
      'hostname': hostname,
      'port': port,
      'username': username,
      'password': password,
      'user_salt': user_salt,
      'cwd_server': cwd_server,
      'cwd_client': cwd_client,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'session{session_id: $session_id, hostname: $hostname, port: $port,username: $username, password: $password, user_salt: $user_salt, cwd_server: $cwd_server, cwd_client $cwd_server}';
  }

}