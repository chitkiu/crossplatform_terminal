import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/cloud_net_v3_info_screen.dart';
import '../domain/content_models.dart';

abstract class ClickListener {
  void onItemClicked(ContentModel item, BuildContext context);
}

class CloudNetV3ClickListener extends ClickListener {
  @override
  void onItemClicked(ContentModel item, BuildContext context) {
    if(item is CloudNetV3ServerModel) {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (ctxt) => CloudNetV3Screen(item)),
      );
    }
  }
}
