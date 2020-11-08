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

  factory SSHConnectionModel.fromJSON(Map<String, dynamic> json) {
    dynamic auth = json['auth'];
    String username;
    if(json.containsKey('username')) {
      username = json['username'];
    }
    if(username == null) {
      if(auth != null) {
        username = auth['username'];
      }
    }

    String password;
    if(json.containsKey('password')) {
      password = json['password'];
    }
    if(password == null) {
      if(auth != null) {
        password = auth['password'];
      }
    }

    String privateKey;
    if(auth != null) {
      privateKey = auth['privateKey'];
    }
    return SSHConnectionModel(
      json['name'] as String,
      json['host'] as String,
      json['port'] as int,
      sshUsername: username,
      sshPassword: password,
      sshPrivateKey: privateKey,
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
  AuthDataModel(this.id, title, this.username, {
    this.password,
    this.privateKey
  }) : super(title);

  final String id;
  final String username;
  final String password;
  final String privateKey;

  factory AuthDataModel.fromJSON(dynamic json) {
    return AuthDataModel(
        json['id'] as String,
        json['name'] as String,
        json['username'] as String,
        password: json['password'] as String,
        privateKey: json['privateKey'] as String
    );
  }
}

class CloudNetV3ServerModel extends ContentModel {
  CloudNetV3ServerModel(this.id, title,
      this.serverUrl,
      this.serverPort,
      this.username,
      this.password,
      this.useHttps,
      {this.screenPort = 80}) : super(title);

  final String id;
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


  @override
  String toString() {
    return 'CloudNetV3ServerModel{id: $id, serverUrl: $serverUrl, serverPort: $serverPort, username: $username, password: $password, screenPort: $screenPort, useHttps: $useHttps}';
  }

  CloudNetV3ServerModel copyWith({ id, title, serverUrl, serverPort, username, password, useHttps, screenPort}) {
    return CloudNetV3ServerModel(
      id ?? this.id,
      title ?? this.title,
      serverUrl ?? this.serverUrl,
      serverPort ?? this.serverPort,
      username ?? this.username,
      password ?? this.password,
      useHttps ?? this.useHttps,
      screenPort: screenPort ?? this.screenPort
    );
  }

  factory CloudNetV3ServerModel.fromJSON(dynamic json) {
    return CloudNetV3ServerModel(
      json['id'] as String,
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
