import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/api/cloudnet_v3_requests.dart';
import '../domain/content_models.dart';
import '../color_constants.dart';
import 'click_listener.dart';
import 'package:http_auth/http_auth.dart';
import 'package:http/http.dart' as http;

abstract class ListChildProvider {
  Widget provide(ContentModel model, BuildContext context);
}

class SSHChildProvider extends ListChildProvider {
  SSHClickListener _clickListener = SSHClickListener();

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

class FTPChildProvider extends ListChildProvider {
  FTPClickListener _clickListener = FTPClickListener();

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

class CloudNetV3ChildProvider extends ListChildProvider {
  // FTPClickListener _clickListener = FTPClickListener();

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
          if(model is CloudNetV3ServerModel) {
            var request = CloudNetV3Requests(model);
            request.login().asStream().listen((event) {
              request.getStatus().then((value) {
                // print(value);
              }/*, onError: (e) {
                if(e is DioError) {
                  print('Error response: '+e.response.toString());
                  print('Error request: '+e.request.toString());
                } else {
                  print(e.toString());
                }
              }*/);
            });
          }
          // _clickListener.onItemClicked(model, context);
        },
      );
}
