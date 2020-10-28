
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/content_models.dart';
import 'entities/response.dart';

class HttpApiRequests {
  HttpApiRequests(
    this.scheme,
    this.host
  );

  final String scheme;
  /// Host should be with port
  final String host;

  /*Stream<List<SSHConnectionModel>> getServers() {
    return http.get('$scheme://$host/servers')
        .then((value) {
          var list = JsonDecoder().convert(value.body) as List;
          return list.map((e) => SSHConnectionModel.fromJSON(e)).toList();
    })
        .catchError((error) {
          print("Error: $error");
        })
        .asStream();
  }*/

  Future<ResponseData> login(String user, String password) {
    Dio dio = Dio(BaseOptions(
        baseUrl:
        "$scheme://$host",
        contentType: "application/json"
    )
    );
    return dio.post<String>(
        "/login",
        data: {"name": user, "password": password },
        ).then((response) {
      dynamic data = JsonDecoder().convert(response.data);
      if (data is Map) {
        if(data.containsKey("token")) {
          return ResponseData(
            success: "true"
          );
        } else if(data.containsKey("error")) {
          return ResponseData(
              error: data['error']
          );
        }
      }
      return ResponseData(
        error: "Cannot auth"
      );
    });
  }

}
