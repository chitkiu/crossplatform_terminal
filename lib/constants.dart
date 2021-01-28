import 'package:biometric_storage/biometric_storage.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/widgets.dart';

import 'data/api/http_requests.dart';

class Constants {
  static bool supportsAuthenticated = false;
  static Map<String, BiometricStorageFile> _storageMap = Map();

  static Future init(String serverURL) {
    if(requests == null) {
      requests = HttpApiRequests(serverURL);
    }
    return Constants.checkAuthenticate().then((authenticate) {
      if (authenticate == CanAuthenticateResponse.success) {
        Constants.supportsAuthenticated = true;
      } else if (authenticate !=
          CanAuthenticateResponse.unsupported) {
        Constants.supportsAuthenticated = false;
      } else {
        debugPrint('Unable to use authenticate. Unable to get storage.');
      }
    });
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

  static Future<String> getSecureData(String key) async {
    if(_storageMap.containsKey(key)) {
      return _storageMap[key].read();
    } else {
      if (supportsAuthenticated) {
        BiometricStorageFile _authStorage = await BiometricStorage().getStorage(
            key,
            options: StorageFileInitOptions(
                authenticationValidityDurationSeconds: 30));
        _storageMap[key] = _authStorage;
        return _authStorage.read();
      } else {
        BiometricStorageFile _authStorage = await BiometricStorage()
            .getStorage(key,
            options: StorageFileInitOptions(
              authenticationRequired: false,
            ));
        _storageMap[key] = _authStorage;
        return _authStorage.read();
      }
    }
  }

  static Future saveSecureData(String key, value) async {
    if(_storageMap.containsKey(key)) {
      return _storageMap[key].write(value);
    } else {
      if (supportsAuthenticated) {
        BiometricStorageFile _authStorage = await BiometricStorage().getStorage(
            key,
            options: StorageFileInitOptions(
                authenticationValidityDurationSeconds: 30));
        _storageMap[key] = _authStorage;
        return _authStorage.write(value);
      } else {
        BiometricStorageFile _authStorage = await BiometricStorage()
            .getStorage(key,
            options: StorageFileInitOptions(
              authenticationRequired: false,
            ));
        _storageMap[key] = _authStorage;
        return _authStorage.write(value);
      }
    }
  }

  static Future<CanAuthenticateResponse> checkAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();
    debugPrint('checked if authentication was possible: $response');
    return response;
  }

  static HttpApiRequests requests;

  static const String SERVER_NAME_PREF = "server_url";
  static const String LOGIN_PREF = "login";
  static const String PASSWORD_PREF = "pass";
  static const String TOKEN_PREF = "token";
}