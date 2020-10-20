import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/domain/content_models.dart';
import 'package:http_auth/http_auth.dart';

import 'entities/cloud_net_v3_service.dart';
import 'entities/cloud_net_v3_status.dart';

class CloudNetV3Requests {
  CloudNetV3Requests(this._data);
  
  final CloudNetV3ServerModel _data;

  String _authMap = '';
  Dio _dio;

  Future<List<CloudNetV3Service>> getServices() {
    _init();
    return _dio.get('/api/v1/services').then((value) {
      return (value.data as List).map((e) => CloudNetV3Service.fromJSON(e)).toList();
    });
  }

  Future<CloudNetV3Status> getStatus() {
    _init();
    return _dio.get('/api/v1/status').then((value) {
      return CloudNetV3Status.fromJSONMap(value.data);
    });
  }

  Future<void> login() async {
    _init();
    var client = BasicAuthClient(_data.username, _data.password);
    return client.get('https://'+_data.serverUrl+'/api/v1/auth').then((response) {
      _authMap = response.headers['set-cookie'];
    });
  }

  Future<WebSocket> screenStream(CloudNetV3Service service) {
    _init();
    var header = Map<String, String>();
    header.putIfAbsent('cookie', () => _authMap);
    return WebSocket.connect(
        "wss://${_data.serverUrl}/screen/${service.serviceId.taskName}-${service.serviceId.taskServiceId}",
        headers: header
    );
  }

  void _init() {
    if(_dio == null) {
      BaseOptions options = new BaseOptions(
        baseUrl: 'https://'+_data.serverUrl,
        connectTimeout: 15000,
        receiveTimeout: 13000,
      );
      _dio = Dio(options);
      _dio.interceptors.add(InterceptorsWrapper(
          onRequest:(Options options) async {
            _dio.interceptors.requestLock.lock();
            options.headers['cookie'] = _authMap;
            _dio.interceptors.requestLock.unlock();
            return options; //continue
          }
      ));
    }
  }

}
