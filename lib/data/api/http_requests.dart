
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

  Map<String, String> _authHeader;

  Future<List<AuthDataModel>> getAuthData() {
    Dio dio = Dio(BaseOptions(
        baseUrl:
        "$scheme://$host",
        contentType: "application/json",
        headers: _authHeader
    )
    );
    return dio.get<String>(
      "/auth"
    ).then((response) {
      dynamic data = JsonDecoder().convert(response.data);

      if (data is List) {
        return data.map((e) => AuthDataModel.fromJSON(e)).toList();
      } else {
        return Future.error("Cannot parse data");
      }
    });
  }

  Future<List<SSHConnectionModel>> getSSHServers() {
    Dio dio = Dio(BaseOptions(
        baseUrl:
        "$scheme://$host",
        contentType: "application/json",
        headers: _authHeader
    )
    );
    return dio.get<String>(
      "/sshserver"
    ).then((response) {
      dynamic data = JsonDecoder().convert(response.data);

      if (data is List) {
        return data.map((e) => SSHConnectionModel.fromJSON(e)).toList();
      } else {
        return Future.error("Cannot parse data");
      }
    });
  }

  Future<List<CloudNetV3ServerModel>> getCloudNetV3Servers() {
    Dio dio = Dio(BaseOptions(
        baseUrl:
        "$scheme://$host",
        contentType: "application/json",
        headers: _authHeader
    )
    );
    return dio.get<String>(
      "/cloudnet"
    ).then((response) {
      dynamic data = JsonDecoder().convert(response.data);

      if (data is List) {
        return data.map((e) => CloudNetV3ServerModel.fromJSON(e)).toList();
      } else {
        return Future.error("Cannot parse data");
      }
    });
  }

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
          _authHeader = Map()..putIfAbsent("Authorization", () => "Bearer ${data["token"]}");
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
