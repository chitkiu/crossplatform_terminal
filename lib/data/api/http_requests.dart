
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/content_models.dart';

class HttpApiRequests {
  HttpApiRequests({
    this.scheme,
    this.host,
  });

  final String scheme;
  /// Host should be with port
  final String host;

  Stream<List<SSHConnectionModel>> getServers() {
    return http.get('$scheme://$host/servers')
        .then((value) {
          var list = JsonDecoder().convert(value.body) as List;
          return list.map((e) => SSHConnectionModel.fromJSON(e)).toList();
    })
        .catchError((error) {
          print("Error: $error");
        })
        .asStream();
  }

}
