import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/api/http_requests.dart';

import '../../color_constants.dart';
import '../click_listener.dart';
import '../list_child_provider.dart';
import '../../domain/repositories/base_model_repository.dart';
import '../../domain/repositories/ftp_model_repository.dart';
import '../../domain/repositories/ssh_model_repository.dart';

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
                      var api = HttpApiRequests(
                          scheme: "http",
                          host: "localhost:8080"
                      );
                      _setSSHState();
                      _disposable = api.getServers().listen((event) {
                        setState(() {
                          _repo.setModels(event);
                        });
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                      'SFTP connection',
                      style: TextStyle(
                          color: ColorConstant.mainText
                      ),
                    ),
                    onTap: () {
                      _setFTPState();
                      Navigator.pop(context);
                    },
                  ),
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
    _disposable = null;
    _repo = SSHModelRepository();
    _listChildProvider = SSHChildProvider();
  }

  void _cancelDisposable() {
    if(_disposable != null) {
      _disposable.cancel();
      _disposable = null;
    }
  }

  void _setSSHState() {
    _cancelDisposable();
    setState(() {
      _repo = SSHModelRepository();
      _listChildProvider = SSHChildProvider();
    });
  }

  void _setFTPState() {
    _cancelDisposable();
    setState(() {
      _repo = FTPModelRepository();
      _listChildProvider = FTPChildProvider();
    });
  }
}
