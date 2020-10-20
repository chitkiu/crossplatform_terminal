import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/screens/cloud_net_v3_info_screen.dart';

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
        new MaterialPageRoute(builder: (ctxt) => SSHTerminalScreen(item)
        ),
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

class CloudNetV3ClickListener extends ClickListener {
  @override
  void onItemClicked(ContentModel item, BuildContext context) {
    if(item is CloudNetV3ServerModel) {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (ctxt) => CloudNetV3Screen(item)
        ),
      );
    }
  }
}
