abstract class ContentModel {
  ContentModel(this.title);

  final String title;
}

class SSHConnectionModel extends ContentModel {
  SSHConnectionModel(title, this.sshHost, this.sshPort, {
    this.sshUsername,
    this.sshPassword,
    this.sshPrivateKey
  }) : super(title) {
    assert(sshHost != null);
    assert(sshHost.isNotEmpty);
    assert(sshPort != null);
    assert(sshPort > 0);
  }

  final String sshHost;
  final int sshPort;
  final String sshUsername;
  final String sshPassword;
  final String sshPrivateKey;

  factory SSHConnectionModel.fromJSON(dynamic json) {
    return SSHConnectionModel(
      json['name'] as String,
      json['host'] as String,
      json['port'] as int,
      sshUsername: json['username'] as String ?? '',
      sshPassword: json['password'] as String ?? '',
    );
  }
}

class FTPConnectionModel extends ContentModel {
  FTPConnectionModel(title, this.host, this.port, this.username, {
    this.password,
    this.privateKey,
    this.startDir
  }) : super(title) {
    assert(host != null);
    assert(host.isNotEmpty);
    assert(port != null);
    assert(port > 0);
    assert(username != null);
    assert(username.isNotEmpty);
  }

  final String host;
  final int port;
  final String username;
  final String password;
  final String privateKey;
  final String startDir;
}

class AuthDataModel extends ContentModel {
  AuthDataModel(title, this.username, {
    this.password,
    this.privateKey
  }) : super(title);

  final String username;
  final String password;
  final String privateKey;
}

class CloudNetV3ServerModel extends ContentModel {
  CloudNetV3ServerModel(this.id, title,
      this.serverUrl,
      this.serverPort,
      this.username,
      this.password,
      this.useHttps,
      {this.screenPort = 80}) : super(title);

  final int id;
  final String serverUrl;
  final int serverPort;
  final String username;
  final String password;
  final int screenPort;
  final bool useHttps;

  String getScheme() {
    if (useHttps) {
      return "https";
    } else {
      return "http";
    }
  }

  String getWebSocketScheme() {
    if (useHttps) {
      return "wss";
    } else {
      return "ws";
    }
  }


  factory CloudNetV3ServerModel.fromJSON(dynamic json) {
    return CloudNetV3ServerModel(
      json['id'] as int,
      json['name'] as String,
      json['serverUrl'] as String,
      json['serverPort'] as int,
      json['username'] as String,
      json['password'] as String,
      json['useSsl'] as bool,
      screenPort: json['screenPort'] as int
    );
  }
}
