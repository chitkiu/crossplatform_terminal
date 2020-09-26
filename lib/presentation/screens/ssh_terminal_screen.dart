import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dartssh/client.dart';
import 'package:dartssh/identity.dart';
import 'package:dartssh/pem.dart';
import 'package:dartssh/transport.dart';
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final SSHConnectionModel sshConnectionInfo;

  @override
  _SSHTerminalScreenState createState() => _SSHTerminalScreenState(
    sshConnectionInfo: sshConnectionInfo
  );
}

class _SSHTerminalScreenState extends State<SSHTerminalScreen> {
  _SSHTerminalScreenState({
    @required this.sshConnectionInfo,
  }) : super();

  final SSHConnectionModel sshConnectionInfo;

  Terminal _terminal;
  SSHClient _sshClient;

  FocusNode _terminalFocusNode;

  @override
  void initState() {
    super.initState();
    _terminalFocusNode = FocusNode();

    _terminal = Terminal(
      onInput: _onInput,
    );

    _sshClient = SSHClient(
        hostport: Uri(scheme: 'ssh', host: sshConnectionInfo.sshHost, port: sshConnectionInfo.sshPort),
        termvar: 'xterm',
        login: sshConnectionInfo.sshUsername,
        getPassword: () => _getPassword(),
        response: (SSHTransport transport, String somestring) => _terminal.write(somestring),
        loadIdentity: _getPrivateKey
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      var mediaQuery = MediaQuery.of(context);
      var padding = mediaQuery.padding;
      double height = mediaQuery.size.height - padding.top - padding.bottom;
      double width = mediaQuery.size.width - padding.left - padding.right;

      _terminal.resize(width.toInt(), height.toInt());

      _sshClient.termHeight = _terminal.viewHeight;
      _sshClient.termWidth = _terminal.viewWidth;
    }
  }

  void _onInput(String input) {
    _sshClient.sendChannelData(utf8.encode(input));
    // FocusScope.of(context).requestFocus(_terminalFocusNode);
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
            color: ColorConstant.appBarText
        ),
        backgroundColor: ColorConstant.appBarBackground,
        title: Text(
            sshConnectionInfo.sshHost,
            style: TextStyle(
                color: ColorConstant.appBarText
            )
        ),
        centerTitle: true,
      ),
      body: TerminalView(
        terminal: _terminal,
        fontSize: 14,
        focusNode: _terminalFocusNode,
        // scrollController: TrackingScrollController(),
      ),
    );
  }
}