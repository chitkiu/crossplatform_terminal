import 'package:flutter/material.dart';

import '../../color_constants.dart';
import '../../constants.dart';
import '../../widget_builder.dart';
import '../../data/api/entities/response.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<StatefulWidget> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: ColorConstant.mainText);

  TextEditingController _serverURLController = TextEditingController();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _passwordLoadedFromStorage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final serverField = MainWidgetBuilder.textInput("Server URL", _serverURLController);
    final loginField = MainWidgetBuilder.textInput("Login", _loginController);
    final passwordField = MainWidgetBuilder.textInput("Password", _passwordController, obscureText: true);

    final loginButton = Material(
      color: ColorConstant.mainButton,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if(_serverURLController.text.isEmpty
              || _loginController.text.isEmpty
              || _passwordController.text.isEmpty) {
            return;
          }

          _auth().then((value) {
            if(value.success == "true") {
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(builder: (ctxt) => MainScreen()
                ),
              );
            } else {
              _passwordController.clear();
            }
          });
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: ColorConstant.mainText, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: FutureBuilder(
        future: _getValidateResponse(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            if (snapshot.data is ResponseData && (snapshot.data as ResponseData).isSuccess()) {
              return MainScreen();
            } else {
              return Center(
                child: Container(
                  color: ColorConstant.mainBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 45.0),
                        serverField,
                        SizedBox(height: 45.0),
                        loginField,
                        SizedBox(height: 25.0),
                        passwordField,
                        SizedBox(
                          height: 35.0,
                        ),
                        loginButton,
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<ResponseData> _getValidateResponse() {
    Future<ResponseData> result = Future.value(ResponseData(error: "Don't have saved session"));
    return Constants.getData(Constants.SERVER_NAME_PREF).then((serverUrl) {
      if(serverUrl.isNotEmpty) {
        _serverURLController.text = serverUrl;
        return _loadAuthData().then((value) {
          if(_loginController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
            return _auth();
          } else {
            return result;
          }
        });
      } else {
        return result;
      }
    });
  }

  Future _loadAuthData() {
    return Constants.getData(Constants.LOGIN_PREF).then((value) {
      if(value.isNotEmpty) {
        _loginController.text = value;
      }
      Constants.getSecureData(Constants.PASSWORD_PREF).then((value) {
        if(value != null && value.isNotEmpty) {
          _passwordLoadedFromStorage = true;
          _passwordController.text = value;
        }
      });
    });
  }

  Future<ResponseData> _auth() {
    return Constants.init(_serverURLController.text).then((value) {
      return Constants.requests.login(_loginController.text, _passwordController.text).then((response) {
        if(response.isSuccess()) {
          return Constants.saveData(Constants.SERVER_NAME_PREF, _serverURLController.text).then((value) {
            Constants.saveData(Constants.LOGIN_PREF, _loginController.text);
          }).then((value) {
            if(!_passwordLoadedFromStorage) {
              Constants.saveSecureData(Constants.PASSWORD_PREF, _passwordController.text);
            }
          }).then((value) {
            return Future.value(ResponseData(success: "true"));
          });
        } else {
          return Future.value(ResponseData(error: "Don't have saved session"));
        }
      });
    });
  }

}