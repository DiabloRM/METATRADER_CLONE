class MT5Settings {
  final String server;
  final int port;
  final String login;
  final String password;
  final bool useEncryption;
  final double defaultDeposit;

  MT5Settings({
    required this.server,
    required this.port,
    required this.login,
    required this.password,
    required this.useEncryption,
    required this.defaultDeposit,
  });

  Map<String, dynamic> toJson() => {
        'server': server,
        'port': port,
        'login': login,
        'password': password,
        'useEncryption': useEncryption,
        'defaultDeposit': defaultDeposit,
      };
}
