import 'dart:async';

import "package:async/async.dart";
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../color_constants.dart';
import '../../constants.dart';
import '../../domain/repositories/auth_model_repository.dart';
import '../../domain/repositories/base_model_repository.dart';
import '../../domain/repositories/cloudnet_v3_model_repository.dart';
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
  CancelableOperation _cancelableOperation;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
      List<Widget> menuItems;
      if (kIsWeb) {
        menuItems = _getListForWeb();
      } else {
        menuItems = _getListForNative();
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "TERMINAL BLET",
            style: TextStyle(color: ColorConstant.appBarText),
          ),
          backgroundColor: ColorConstant.appBarBackground,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: menuItems,
          ),
        ),
        body: ListView.builder(
            itemCount: _repo.getModels().length,
            itemBuilder: (BuildContext ctxt, int index) {
              return _listChildProvider.provide(_repo[index], ctxt);
            }),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: _refreshData,
        ),
      );
    });
  }

  List<Widget> _getListForNative() {
    return <Widget>[
      ListTile(
        hoverColor: ColorConstant.mainHover,
        title: Text('SSH connection',
            style: TextStyle(color: ColorConstant.mainText)),
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
          style: TextStyle(color: ColorConstant.mainText),
        ),
        onTap: () {
          _handleFTPClick();
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      ),
      ListTile(
        hoverColor: ColorConstant.mainHover,
        title: Text(
          'Auth data',
          style: TextStyle(color: ColorConstant.mainText),
        ),
        onTap: () {
          _handleAuthClick();
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      ),
      ListTile(
        hoverColor: ColorConstant.mainHover,
        title: Text(
          'CloudNet V3 servers',
          style: TextStyle(color: ColorConstant.mainText),
        ),
        onTap: () {
          _handleCloudNetV3Click();
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      )
    ];
  }

  List<Widget> _getListForWeb() {
    return <Widget>[
      ListTile(
        hoverColor: ColorConstant.mainHover,
        title: Text(
          'Auth data',
          style: TextStyle(color: ColorConstant.mainText),
        ),
        onTap: () {
          _handleAuthClick();
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      ),
      ListTile(
        hoverColor: ColorConstant.mainHover,
        title: Text(
          'CloudNet V3 servers',
          style: TextStyle(color: ColorConstant.mainText),
        ),
        onTap: () {
          _handleCloudNetV3Click();
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    _handleCloudNetV3Click();
  }

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    FocusScope.of(context).unfocus();
  }

  void _refreshData() {
    _cancelDisposable();
    setState(() {
      _repo.clearModels();
    });
    switch (_repo.runtimeType) {
      case SSHModelRepository:
        {
          _warpToCancelable(Constants.requests.getSSHServers().then((value) {
            setState(() {
              _repo.setModels(value);
            });
          }));
        }
        break;
      case AuthModelRepository:
        {
          _warpToCancelable(Constants.requests.getAuthData().then((value) {
            setState(() {
              _repo.setModels(value);
            });
          }));
        }
        break;
      case CloudNetV3ModelRepository:
        {
          _warpToCancelable(
              Constants.requests.getCloudNetV3Servers().then((value) {
            setState(() {
              _repo.setModels(value);
            });
          }));
        }
        break;
    }
  }

  void _handleSSHClick() {
    _setSSHState();

    _warpToCancelable(Constants.requests.getSSHServers().then((value) {
      setState(() {
        _repo.setModels(value);
      });
    }));
  }

  void _handleFTPClick() {
    _setFTPState();

    /*setState(() {
    });*/
  }

  void _handleAuthClick() {
    _setAuthDataState();

    _warpToCancelable(Constants.requests.getAuthData().then((value) {
      setState(() {
        _repo.setModels(value);
      });
    }));
  }

  void _handleCloudNetV3Click() {
    _setCloudNetV3State();

    _warpToCancelable(Constants.requests.getCloudNetV3Servers().then((value) {
      setState(() {
        _repo.setModels(value);
      });
    }));
  }

  void _cancelDisposable() {
    if (_disposable != null) {
      _disposable.cancel();
      _disposable = null;
    }
    if (_cancelableOperation != null) {
      _cancelableOperation.cancel();
      _cancelableOperation = null;
    }
  }

  void _warpToCancelable(Future future) {
    _cancelableOperation = CancelableOperation.fromFuture(future);
  }

  void _setSSHState() {
    _cancelDisposable();
    _repo = SSHModelRepository();
    _listChildProvider = SSHChildProvider();
  }

  void _setFTPState() {
    _cancelDisposable();
    _repo = FTPModelRepository();
    _listChildProvider = FTPChildProvider();
  }

  void _setCloudNetV3State() {
    _cancelDisposable();
    _repo = CloudNetV3ModelRepository();
    _listChildProvider = CloudNetV3ChildProvider();
  }

  void _setAuthDataState() {
    _cancelDisposable();
    _repo = AuthModelRepository();
    _listChildProvider = AuthChildProvider();
  }
}
