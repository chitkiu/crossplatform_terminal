import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_app/domain/content_models.dart';
import 'package:http_auth/http_auth.dart';

import 'entities/cloud_net_v3_status.dart';

class CloudNetV3Requests {
  CloudNetV3Requests(this._data);
  
  final CloudNetV3ServerModel _data;

  String _authMap = '';
  Dio _dio;

  //TODO
  Future<void> getStatus() {
    _init();
    return _dio.get('/api/v1/status').then((value) {
      var data = value.data;
      if(data is Map) {
        print(CloudNetV3Status.fromJSONMap(data));
      }
    });
  }

  Future<void> login() async {
    _init();
    var client = BasicAuthClient(_data.username, _data.password);
    return client.get(_data.serverUrl+'/api/v1/auth').then((response) {
      _authMap = response.headers['set-cookie'];
    });
  }

  void _init() {
    if(_dio == null) {
      BaseOptions options = new BaseOptions(
        baseUrl: _data.serverUrl,
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
