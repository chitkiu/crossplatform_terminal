import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../domain/repositories/cloudnet_v3_model_repository.dart';
import '../../color_constants.dart';
import '../../domain/repositories/base_model_repository.dart';
import '../../domain/repositories/ftp_model_repository.dart';
import '../../domain/repositories/ssh_model_repository.dart';
import '../list_child_provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<StatefulWidget> {

  ModelRepository _repo;
  ListChildProvider _listChildProvider;

  StreamSubscription _disposable;

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  "TERMINAL BLET",
                style: TextStyle(
                  color: ColorConstant.appBarText
                ),
              ),
              backgroundColor: ColorConstant.appBarBackground,
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                        'SSH connection',
                        style: TextStyle(
                            color: ColorConstant.mainText
                        )
                    ),
                    onTap: () {
                      _handleSSHClick();
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                      'FTP connection',
                      style: TextStyle(
                          color: ColorConstant.mainText
                      ),
                    ),
                    onTap: () {
                      _handleFTPClick();
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                  ),ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                      'Auth data',
                      style: TextStyle(
                          color: ColorConstant.mainText
                      ),
                    ),
                    onTap: () {
                      _handleAuthClick();
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                  ),ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                      'CloudNet V3 servers',
                      style: TextStyle(
                          color: ColorConstant.mainText
                      ),
                    ),
                    onTap: () {
                      _handleCloudNetV3Click();
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            body: ListView.builder(
                itemCount: _repo.getModels().length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return _listChildProvider.provide(_repo[index], ctxt);
                }
            ),
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    _setCloudNetV3State();
  }

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    FocusScope.of(context).unfocus();
  }

  void _handleSSHClick() {
    _setSSHState();
    /*var api = HttpApiRequests(
        scheme: "http",
        host: "localhost:8080"
    );
    _disposable = api.getServers().listen(
            (event) {
          var items = event;
          if (event == null) {
            items = List(0);
          }
          setState(() {
            _repo.setModels(items);
          });
        },
        cancelOnError: true,
        onError: (error) {
              setState(() {
                _repo.setModels(List(0));
              });
        });*/
  }

  void _handleFTPClick() {
    _setFTPState();
  }

  void _handleAuthClick() {
    _setAuthDataState();
  }

  void _handleCloudNetV3Click() {
    _setCloudNetV3State();
  }

  void _cancelDisposable() {
    if(_disposable != null) {
      _disposable.cancel();
      _disposable = null;
    }
  }

  void _setSSHState() {
    _cancelDisposable();
    _repo = SSHModelRepository();
    _listChildProvider = SSHChildProvider();

    setState(() {
    });
  }

  void _setFTPState() {
    _cancelDisposable();
    _repo = FTPModelRepository();
    _listChildProvider = FTPChildProvider();

    setState(() {
    });
  }

  void _setCloudNetV3State() {
    _cancelDisposable();
    _repo = CloudNetV3ModelRepository();
    _listChildProvider = CloudNetV3ChildProvider();

    Constants.requests.getCloudNetV3Servers().then((value) {
      setState(() {
        _repo.setModels(value);
      });
    });
  }

  void _setAuthDataState() {
    _cancelDisposable();
    setState(() {
      // _repo = FTPModelRepository();
      // _listChildProvider = FTPChildProvider();
    });
  }
}
