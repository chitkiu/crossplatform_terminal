import 'package:flutter/material.dart';
import '../domain/content_models.dart';
import '../color_constants.dart';
import 'click_listener.dart';

abstract class ListChildProvider {
  Widget provide(ContentModel model, BuildContext context);
}

class CloudNetV3ChildProvider extends ListChildProvider {
  CloudNetV3ClickListener _clickListener = CloudNetV3ClickListener();

  @override
  Widget provide(ContentModel model, BuildContext context) =>
      ListTile(
        hoverColor: ColorConstant.mainHover,
        title: Text(
            model.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: ColorConstant.mainText
            )
        ),
        onTap: () {
          _clickListener.onItemClicked(model, context);
        },
      );
}
