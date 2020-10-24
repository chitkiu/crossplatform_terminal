import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/terminal/terminal.dart';

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

  IOWebSocketChannel _webSocket;
  Terminal _terminal;

  FocusNode _terminalFocusNode;

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _terminalFocusNode = FocusNode();

    _terminal = Terminal();

    _webSocket = _request.screenStream(_service);
    _webSocket.stream.listen(
      (dynamic message) {
        dynamic json = JsonDecoder().convert(message);
        if (json is Map) {
          if (json.containsKey('text')) {
            for (var value in (json['text'] as String).split("\n")) {
              if (value.isNotEmpty && value.trim() != ">") {
                _terminal.write(value + "\r\n");
              }
            }
          }
        }
      },
      onDone: () {
        _closeConnectionAlertDialog();
      },
      onError: (error) {
        debugPrint(error);
      },
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () {
        if (_webSocket != null) {
          return _webSocket.sink.close().then((value) => Future.value(true));
        }
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            leading: BackButton(color: ColorConstant.appBarText),
            backgroundColor: ColorConstant.appBarBackground,
            title: Text(
                "${_service.serviceId.taskName}-${_service.serviceId.taskServiceId}",
                style: TextStyle(color: ColorConstant.appBarText)),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 11,
                child: TerminalView(
                  terminal: _terminal,
                  focusNode: _terminalFocusNode,
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 500,
                      child: TextFormField(
                        controller: _textEditingController,
                        style: TextStyle(color: ColorConstant.mainText),
                        decoration: InputDecoration(
                          labelText: 'Enter your command',
                          labelStyle: TextStyle(color: ColorConstant.hintText),
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        _request
                            .screenSendCommand(_service, _textEditingController.text)
                            .asStream()
                            .listen((event) {
                          _textEditingController.clear();
                        }, onError: (error) {
                              print(error);
                          _textEditingController.clear();
                        });
                      },
                      color: ColorConstant.mainButton,
                      hoverColor: ColorConstant.mainHover,
                      child: Text(
                        "Send command",
                        style: TextStyle(color: ColorConstant.mainText),
                      ),
                    )
                  ],
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
}
