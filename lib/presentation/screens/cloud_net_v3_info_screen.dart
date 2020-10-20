import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/api/entities/cloud_net_v3_service.dart';
import '../../data/api/entities/cloud_net_v3_status.dart';
import '../../data/api/cloudnet_v3_requests.dart';
import '../../color_constants.dart';
import '../../domain/content_models.dart';
import 'cloud_net_v3_terminal.dart';

class CloudNetV3Screen extends StatefulWidget {

  CloudNetV3Screen(this._model, {
    key
  }): super(key: key);

  final CloudNetV3ServerModel _model;

  @override
  State<StatefulWidget> createState() => _CloudNetV3Screen(_model);
}

class _CloudNetV3Screen extends State<CloudNetV3Screen> {

  _CloudNetV3Screen(this._model) : super() {
    _request = CloudNetV3Requests(_model);
  }

  final CloudNetV3ServerModel _model;
  CloudNetV3Requests _request;

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          leading: BackButton(
              color: ColorConstant.appBarText
          ),
          backgroundColor: ColorConstant.appBarBackground,
          title: Text(
              _model.title,
              style: TextStyle(
                  color: ColorConstant.appBarText
              )
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: _request.login().then((value) =>
              _request.getStatus()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is CloudNetV3Status) {
                CloudNetV3Status data = (snapshot.data as CloudNetV3Status);
                return Column(
                  children: [
                    Row(
                      children: [
                        _text("Node name: "),
                        _text(data.info.name)
                      ],
                    ),
                    Row(
                      children: [
                        _text("RAM(reserved/total): "),
                        _text("${data.currentNetworkClusterNodeInfoSnapshot
                            .reservedMemoryInMB}/${data
                            .currentNetworkClusterNodeInfoSnapshot
                            .maxMemoryInMB}")
                      ],
                    ),
                    Row(
                      children: [
                        _text("CPU load: "),
                        _text("${data.currentNetworkClusterNodeInfoSnapshot
                            .systemCpuUsage}")
                      ],
                    ),
                    _text("Services:"),
                    FutureBuilder(
                      future: _request.getServices(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<CloudNetV3Service> data = snapshot.data as List<
                              CloudNetV3Service>;
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              CloudNetV3Service serviceInfo = data[index];
                              return Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        _text("${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId}"),
                                        new Row(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(right: 10),
                                                child: _button("Stop", () {})
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(right: 10),
                                                child: _button("Open Console", () {
                                                  Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(builder: (ctxt) => CloudNetV3Terminal(_request, serviceInfo)),
                                                  );
                                                })
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                    child: Container(
                                      color: ColorConstant.mainHover,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return _text("");
                      },
                    )
                  ],
                );
              } else {
                return _wrongResponse();
              }
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return _cannotAuth();
            }
            return _text("");
          },
        ),
      );

  Widget _cannotAuth() {
    return _text("Auth Error");
  }

  Widget _wrongResponse() {
    return _text("Wrong server response");
  }

  Widget _text(String text) {
    return Text(
      text,
      style: TextStyle(
          color: ColorConstant.mainText
      ),
    );
  }

  Widget _button(String text, VoidCallback clickListener) {
    return RaisedButton(
      onPressed: clickListener,
      color: ColorConstant.mainButton,
      hoverColor: ColorConstant.mainHover,
      child: _text(text),
    );
  }

}
