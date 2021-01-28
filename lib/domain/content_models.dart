abstract class ContentModel {
  ContentModel(this.title);

  final String title;
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
