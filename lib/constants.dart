import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/material.dart';

import 'data/api/http_requests.dart';

class Constants {
  static void init(String serverURL) {
    if(requests == null) {
      requests = HttpApiRequests(serverURL);
    }
  }

  static Future saveData(String key, String value) async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String> getData(String key) async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    if(prefs.containsKey(key)) {
      return prefs.getString(key);
    } else {
      return Future.value("");
    }
  }

  static HttpApiRequests requests;

  static const String SERVER_NAME_PREF = "server_url";
  static const String LOGIN_PREF = "login";
  static const String TOKEN_PREF = "token";
}