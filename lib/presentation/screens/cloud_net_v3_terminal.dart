import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:websocket/websocket.dart';

import '../../data/api/entities/cloud_net_v3_service.dart';
import '../../color_constants.dart';
import '../../data/api/cloudnet_v3_requests.dart';

class CloudNetV3Terminal extends StatefulWidget {
  CloudNetV3Terminal(this._request, this._service, {key}) : super(key: key);

  final CloudNetV3Requests _request;
  final CloudNetV3Service _service;

  @override
  State<StatefulWidget> createState() =>
      _CloudNetV3Terminal(_request, _service);
}

class _CloudNetV3Terminal extends State<CloudNetV3Terminal> {
  _CloudNetV3Terminal(this._request, this._service) : super();

  final CloudNetV3Requests _request;
  final CloudNetV3Service _service;

  WebSocket _webSocket;

  ScrollController _scrollController;
  String _terminalData = "";
  Timer _scrollTimer;
  bool _alreadyScrolled = false;

  TextEditingController _textEditingController = TextEditingController();

  bool _requestClose = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      keepScrollOffset: true
    );
    if(_scrollTimer != null) {
      _scrollTimer.cancel();
    }
    _scrollTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        if(!_alreadyScrolled && _terminalData.isNotEmpty) {
          _scrollToBottom();
          _alreadyScrolled = true;
          return;
        }
        double diff = _getDiff();
        if(diff < 95 && diff > 0) {
          _scrollToBottom();
        }
      } else {
        timer.cancel();
      }
    });
    _request.screenStream(_service).then((websocket) {
      _webSocket = websocket;
      websocket.add("token=${_request.authToken}");
      websocket.stream.listen(
        (dynamic message) {
          dynamic json = JsonDecoder().convert(message);
          if (json is Map) {
            if (json.containsKey('auth_success') &&
                json['auth_success'] == 'true') {
              websocket.add("service=${_service.serviceId.taskName}-${_service.serviceId.taskServiceId}");
            } else if (json.containsKey('text')) {
              for (var value in (json['text'] as String).split("\n")) {
                if (value.isNotEmpty && value.trim() != ">") {
                  _terminalData += (value + "\r\n");
                  setState(() {});
                }
              }
            } else if (json.containsKey('error')) {
              print("error: ${json['error']}");
            }
          }
        },
        onDone: () {
          if (!_requestClose) {
            _closeConnectionAlertDialog();
          }
        },
        onError: (error) {
          print("error: $error");
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () {
        _requestClose = true;
        if (_webSocket != null) {
          return _webSocket.close().then((value) => Future.value(true));
        }
        if(_scrollTimer != null) {
          _scrollTimer.cancel();
        }
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            leading: BackButton(color: ColorConstant.appBarText),
            backgroundColor: ColorConstant.appBarBackground,
            title: Text("${_service.serviceId.taskName}-${_service.serviceId.taskServiceId}",
                style: TextStyle(color: ColorConstant.appBarText)),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              _scrollToBottom();
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 11,
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,//
                    controller: _scrollController,// .horizontal
                    child: new SelectableText(
                      _terminalData,
                      showCursor: false,
                      toolbarOptions: ToolbarOptions(
                          copy: true,
                          selectAll: true,
                          cut: false,
                          paste: false
                      ),
                      style: new TextStyle(
                        fontSize: 16.0, color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Flexible(
                flex: 1,
                child: TextFormField(
                  autofocus: true,
                  controller: _textEditingController,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _sendCommand,
                  style: TextStyle(color: ColorConstant.mainText),
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Enter your command',
                    labelStyle: TextStyle(color: ColorConstant.hintText),
                  ),
                ),
              )
            ],
          )));

  void _closeConnectionAlertDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: new Text("Something wrong"),
        content: new Text("Error has occurred with console :("),
        actions: [
          new FlatButton(
            child: new Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    Navigator.pop(context);
  }

  void _sendCommand() {
    String command = _textEditingController.text;
    if (command.isNotEmpty) {
      _request.screenSendCommand(_service, command).asStream().listen((event) {
        _textEditingController.clear();
      }, onError: (error) {
        print("error: $error");
        _textEditingController.clear();
      });
    }
  }

  double _getDiff() {
    if(_scrollController.hasClients) {
      return _scrollController.position.maxScrollExtent - _scrollController.offset;
    } else {
      return 0;
    }
  }

  void _scrollToBottom() {
    if(_scrollController.hasClients) {
      _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent
      );
    }
  }
}
