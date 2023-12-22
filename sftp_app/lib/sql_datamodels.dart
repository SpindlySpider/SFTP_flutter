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
}