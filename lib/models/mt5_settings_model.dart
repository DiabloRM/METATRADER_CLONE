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

  factory MT5Settings.fromJson(Map<String, dynamic> json) {
    return MT5Settings(
      server: json['server'] ?? '',
      port: json['port'] ?? 443,
      login: json['login'] ?? '',
      password: json['password'] ?? '',
      useEncryption: json['useEncryption'] ?? true,
      defaultDeposit: json['defaultDeposit']?.toDouble() ?? 1000.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'server': server,
        'port': port,
        'login': login,
        'password': password,
        'useEncryption': useEncryption,
        'defaultDeposit': defaultDeposit,
      };
}
