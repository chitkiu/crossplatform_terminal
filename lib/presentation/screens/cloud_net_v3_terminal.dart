import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/terminal/terminal.dart';

import '../../data/api/entities/cloud_net_v3_service.dart';
import '../../color_constants.dart';
import '../../data/api/cloudnet_v3_requests.dart';

class CloudNetV3Terminal extends StatefulWidget {

  CloudNetV3Terminal(this._request, this._service, {
    key
  }): super(key: key);

  final CloudNetV3Requests _request;
  final CloudNetV3Service _service;

  @override
  State<StatefulWidget> createState() => _CloudNetV3Terminal(_request, _service);
}

class _CloudNetV3Terminal extends State<CloudNetV3Terminal> {

  _CloudNetV3Terminal(this._request, this._service) : super();

  final CloudNetV3Requests _request;
  final CloudNetV3Service _service;

  WebSocket _webSocket;
  Terminal _terminal;

  String _inputText = "";

  @override
  Widget build(BuildContext context) =>
      WillPopScope(
        onWillPop: () {
          if(_webSocket != null) {
            return _webSocket.close().then((value) => Future.value(true));
          }
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              leading: BackButton(
                  color: ColorConstant.appBarText
              ),
              backgroundColor: ColorConstant.appBarBackground,
              title: Text(
                  "${_service.serviceId.taskName}-${_service.serviceId.taskServiceId}",
                  style: TextStyle(
                      color: ColorConstant.appBarText
                  )
              ),
              centerTitle: true,
            ),
            body: FutureBuilder(
              future: _request.screenStream(_service),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  if(snapshot.data is WebSocket) {
                    _webSocket = snapshot.data;
                    _terminal = Terminal(
                      onInput: _onInput
                    );
                    _webSocket.listen((event) {
                      dynamic json = JsonDecoder().convert(event);
                      if(json is Map) {
                        bool hasData = json.containsKey('text');
                        if (hasData) {
                          for (var value in (json['text'] as String).split("\n")) {
                            if (value.isNotEmpty && value.trim() != ">") {
                              _terminal.write(value + "\r\n");
                            }
                          }
                        }
                      }
                    });
                    return TerminalView(
                      terminal: _terminal,
                      autofocus: true,
                    );
                  }
                }
                return Text("ERROR");
              },
            )
        ),
      );

  void _onInput(String input) {
      _terminal.write(input);
      if(input != '\r') {
        _inputText += input;
      } else {
        _terminal.write('\r\n');
        print(_inputText);
        _inputText = '';
      }
    }

}
