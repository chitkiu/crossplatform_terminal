import 'dart:async';

import "package:async/async.dart";
import 'package:flutter/material.dart';

import '../../color_constants.dart';
import '../../constants.dart';
import '../../domain/repositories/base_model_repository.dart';
import '../../domain/repositories/cloudnet_v3_model_repository.dart';
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
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Aether Project Control Panel",
            style: TextStyle(color: ColorConstant.appBarText),
          ),
          backgroundColor: ColorConstant.appBarBackground,
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

  @override
  void initState() {
    super.initState();
    _cancelDisposable();
    _repo = CloudNetV3ModelRepository();
    _listChildProvider = CloudNetV3ChildProvider();

    _warpToCancelable(Constants.requests.getCloudNetV3Servers().then((value) {
      setState(() {
        _repo.setModels(value);
      });
    }));
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
}
