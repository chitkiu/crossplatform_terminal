import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/ssh_terminal_screen.dart';
import '../domain/content_models.dart';

abstract class ClickListener {
  void onItemClicked(ContentModel item, BuildContext context);
}

class SSHClickListener extends ClickListener {
  @override
  void onItemClicked(ContentModel item, BuildContext context) {
    if(item is SSHConnectionModel) {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (ctxt) =>
        new SSHTerminalScreen(
            sshConnectionInfo: item
        )),
      );
    }
  }

}

class FTPClickListener extends ClickListener {
  @override
  void onItemClicked(ContentModel item, BuildContext context) {
    if(item is FTPConnectionModel) {
      //TODO FTPScreen
     /* Navigator.push(
        context,
        new MaterialPageRoute(builder: (ctxt) =>
        new SSHTerminalScreen(
            sshConnectionInfo: item
        )),
      );*/
    }
  }

}
