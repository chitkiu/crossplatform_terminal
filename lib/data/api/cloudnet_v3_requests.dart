import 'dart:convert';

import 'package:dio/dio.dart';
import '../../domain/content_models.dart';
import 'package:websocket/websocket.dart';

import 'entities/cloud_net_v3_service.dart';
import 'entities/cloud_net_v3_status.dart';

class CloudNetV3Requests {
  CloudNetV3Requests(this._data);

  final CloudNetV3ServerModel _data;

  Map<String, String> _authHeader;
  String authToken;

  Future<List<CloudNetV3Service>> getServices() {
    Dio dio = Dio(BaseOptions(
        baseUrl:
            "${_data.getScheme()}://${_data.serverUrl}:${_data.serverPort}",
        headers: _authHeader));
    return dio.get<String>("/api/services").then((response) {
      dynamic data = JsonDecoder().convert(response.data);
      if (data is List) {
        return data.map((e) => CloudNetV3Service.fromJSON(e)).toList();
      } else {
        return Future.error("Cannot parse JSON");
      }
    });
  }

  Future<CloudNetV3Status> getStatus() {
    Dio dio = Dio(BaseOptions(
        baseUrl:
            "${_data.getScheme()}://${_data.serverUrl}:${_data.serverPort}",
        headers: _authHeader));
    return dio.get<String>("/api/status").then((response) {
      dynamic data = JsonDecoder().convert(response.data);
      if (data is Map) {
        return CloudNetV3Status.fromJSONMap(data);
      } else {
        return Future.error("Cannot parse JSON");
      }
    });
  }

  Future<void> login() async {
    var authMap = Map<String, String>();
    authMap.putIfAbsent(
        'Authorization',
        () =>
            'Basic ${base64Encode(utf8.encode('${_data.username}:${_data.password}'))}');
    Dio dio = Dio(BaseOptions(
        baseUrl:
            "${_data.getScheme()}://${_data.serverUrl}:${_data.serverPort}",
        headers: authMap));
    return dio.get<String>("/auth").then((response) {
      // debugPrint(response.data);
      dynamic data = JsonDecoder().convert(response.data);
      if (data is Map) {
        authToken = data['token'];
        var authMap = Map<String, String>();
        authMap.putIfAbsent('token', () => data['token']);
        _authHeader = authMap;
      }
    });
  }

  Future<WebSocket> screenStream(CloudNetV3Service service) {
    return WebSocket.connect(
      "${_data.getWebSocketScheme()}://${_data.serverUrl}:${_data.screenPort}",
    );
  }

  Future<void> screenSendCommand(CloudNetV3Service service, String command) {
    Map headers = Map<String, String>()..addAll(_authHeader);
    headers.putIfAbsent(
        "command", () => utf8.encoder.convert(command).toString());
    Dio dio = Dio(BaseOptions(
        baseUrl:
            "${_data.getScheme()}://${_data.serverUrl}:${_data.serverPort}",
        headers: headers));
    return dio
        .post<String>(
            "/api/command/${service.serviceId.taskName}-${service.serviceId.taskServiceId}")
        .then((response) {
      // debugPrint(response.data);
      dynamic data = JsonDecoder().convert(response.data);
      if (data is Map) {
        if (data.containsKey('status')) {
          return Future.value();
        }
      }
      return Future.error("Cannot send command");
    });
  }
}
