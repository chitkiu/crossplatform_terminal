import 'dart:convert';
import 'dart:io';

import 'package:dartssh/client.dart';
import 'package:dartssh/identity.dart';
import 'package:dartssh/pem.dart';
import 'package:flutter/material.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/terminal/terminal.dart';

import '../../color_constants.dart';
import '../../domain/content_models.dart';

class SSHTerminalScreen extends StatefulWidget {
  SSHTerminalScreen({
    key,
    @required this.sshConnectionInfo,
  }) : super(key: key);

  final SSHConnectionModel sshConnectionInfo;

  @override
  _SSHTerminalScreenState createState() => _SSHTerminalScreenState(sshConnectionInfo);
}

class _SSHTerminalScreenState extends State<SSHTerminalScreen> {
  _SSHTerminalScreenState(this.sshConnectionInfo) : super();

  final SSHConnectionModel sshConnectionInfo;

  Terminal _terminal;
  SSHClient _sshClient;

  FocusNode _terminalFocusNode;

  bool _mobileButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _terminalFocusNode = FocusNode();

    _terminal = Terminal(
      onInput: _onInput,
      onBell: () {
        //TODO: Add sound
        print("initState onBell");
      },
    );

    _sshClient = SSHClient(
        hostport: Uri(scheme: 'ssh',
            host: sshConnectionInfo.sshHost,
            port: sshConnectionInfo.sshPort),
        termvar: 'xterm-256color',
        login: sshConnectionInfo.sshUsername,
        getPassword: () => _getPassword(),
        response: (transport, data) {
          FocusScope.of(context).requestFocus(_terminalFocusNode);
          _terminal.write(data);
        },
        loadIdentity: _getPrivateKey,
        closeOnDisconnect: true,
        disconnected: _onDisconnect,
        success: _onSuccessConnection,
        acceptHostFingerprint: (hostkeyType, keyFingerPrint) {
          // String keyName = Key.name(hostkeyType);
          //TODO: Show dialog
          // Do you accept $keyName with fingerprint
          // keyFingerPrint ?
          return true;
        }
    );
  }

  void _onInput(String input) {
    _sshClient.sendChannelData(utf8.encode(input));
  }

  void _onDisconnect() {
    print("SSH connection was closed");
    Navigator.pop(context);
  }

  void _onSuccessConnection() {
    FocusScope.of(context).requestFocus(_terminalFocusNode);
  }

  List<int> _getPassword() {
    if(sshConnectionInfo.sshPassword != null) {
      return utf8.encode(sshConnectionInfo.sshPassword);
    } else {
      return null;
    }
  }

  Identity _getPrivateKey() {
    if(sshConnectionInfo.sshPrivateKey != null) {
      return parsePem(sshConnectionInfo.sshPrivateKey);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: ColorConstant.appBarText,
          onPressed: () {
            _sshClient.disconnect("");
          },
        ),
        backgroundColor: ColorConstant.appBarBackground,
        title: Text(
            sshConnectionInfo.title,
            style: TextStyle(
                color: ColorConstant.appBarText
            )
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
          onTap: () {
            print("onTap");
          },
          onTapDown: (info) {
            print("onTapDown");
            setState(() {
              _mobileButtonVisible = !_mobileButtonVisible /*&&
                  (Platform.isAndroid || Platform.isIOS)*/;
            });
          },
          child: Container(
            child: Stack(
              children: [
                TerminalView(
                    terminal: _terminal,
                    autofocus: true,
                    focusNode: _terminalFocusNode,
                    onResize: (width, height) {
                      _sshClient.setTerminalWindowSize(width, height);
                    }
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: _mobileButtonVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("KEYBOARD",
                          style: TextStyle(
                              color: Colors.amberAccent
                          ),
                        ),
                        Text("KEYBOARD1",
                          style: TextStyle(
                              color: Colors.amberAccent
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}