import 'package:flutter/cupertino.dart';

class SSHConnectionInfo {
  SSHConnectionInfo({
    @required this.sshHost,
    @required this.sshPort,
    @required this.sshUsername,
    this.sshPassword,
    this.sshPrivateKey
  }) {
    assert (sshHost != null);
    assert (sshHost.isNotEmpty);
    assert (sshPort != null);
    assert (sshPort > 0);
    assert (sshUsername != null);
    assert (sshUsername.isNotEmpty);
  }

  final String sshHost;
  final int sshPort;
  final String sshUsername;
  final String sshPassword;
  final String sshPrivateKey;

}
