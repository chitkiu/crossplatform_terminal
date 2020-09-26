import 'package:flutter/widgets.dart';

abstract class ContentModel {
  ContentModel(this.title);

  final String title;

}

class SSHConnectionModel extends ContentModel {
  SSHConnectionModel(title, {
    @required this.sshHost,
    @required this.sshPort,
    @required this.sshUsername,
    this.sshPassword,
    this.sshPrivateKey
  }) : super(title) {
    assert (sshHost != null);
    assert (sshHost.isNotEmpty);
    assert (sshPort != null);
    assert (sshPort > 0);
    // assert (sshUsername != null);
    // assert (sshUsername.isNotEmpty);
  }

  final String sshHost;
  final int sshPort;
  final String sshUsername;
  final String sshPassword;
  final String sshPrivateKey;

  factory SSHConnectionModel.fromJSON(dynamic json) {
    return SSHConnectionModel(
      json['name'] as String,
      sshHost: json['host'] as String,
      sshPort: json['port'] as int,
      sshUsername: json['username'] as String ?? '',
      sshPassword: json['password'] as String ?? '',
    );
  }

}

class FTPConnectionModel extends ContentModel {
  FTPConnectionModel(title, {
    @required this.host,
    @required this.port,
    @required this.username,
    this.password,
    this.privateKey,
    this.startDir,
  }) : super(title) {
    assert (host != null);
    assert (host.isNotEmpty);
    assert (port != null);
    assert (port > 0);
    assert (username != null);
    assert (username.isNotEmpty);
  }

  final String host;
  final int port;
  final String username;
  final String password;
  final String privateKey;
  final String startDir;

}
