import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/api/entities/cloud_net_v3_service.dart';
import '../../data/api/entities/cloud_net_v3_status.dart';
import '../../data/api/cloudnet_v3_requests.dart';
import '../../color_constants.dart';
import '../../domain/content_models.dart';
import '../../widget_builder.dart';
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

  static const double DEFAULT_PADDING = 5;
  static const double LANDSCAPE_PADDING = 40;

  _CloudNetV3Screen(this._model) : super() {
    _request = CloudNetV3Requests(_model);
    _requestData = _dataRequest();
  }

  Future<CloudNetV3Status> _requestData;

  CloudNetV3ServerModel _model;
  CloudNetV3Requests _request;

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: MainWidgetBuilder.appBar(
            _model.title,
            leading: BackButton(
                color: ColorConstant.appBarText
            )
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return FutureBuilder(
              future: _requestData,
              builder: (context, snapshot) {
                double paddingDependOnOrientation = _getPaddingDependOnOrientation(orientation);
                if (snapshot.hasData) {
                  if (snapshot.data is CloudNetV3Status) {
                    CloudNetV3Status data = (snapshot.data as CloudNetV3Status);
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              MainWidgetBuilder.text(
                                  "Node name: ",
                                  topPadding: 10,
                                  leftPadding: paddingDependOnOrientation
                              ),
                              MainWidgetBuilder.text(
                                  data.info.name,
                                  topPadding: 10,
                                  rightPadding: paddingDependOnOrientation
                              )
                            ],
                          ),
                          Row(
                            children: [
                              MainWidgetBuilder.text(
                                  "RAM(reserved/total): ",
                                  topPadding: 10,
                                  leftPadding: paddingDependOnOrientation
                              ),
                              MainWidgetBuilder.text(
                                  "${data.currentNetworkClusterNodeInfoSnapshot.reservedMemoryInMB}"
                                      +"/${data.currentNetworkClusterNodeInfoSnapshot.maxMemoryInMB}",
                                  topPadding: 10,
                                  rightPadding: paddingDependOnOrientation
                              )
                            ],
                          ),
                          Row(
                            children: [
                              MainWidgetBuilder.text(
                                  "CPU load: ",
                                  topPadding: 10,
                                  leftPadding: paddingDependOnOrientation
                              ),
                              MainWidgetBuilder.text(
                                  "${data.currentNetworkClusterNodeInfoSnapshot.systemCpuUsage}",
                                  topPadding: 10,
                                  rightPadding: paddingDependOnOrientation
                              )
                            ],
                          ),
                          MainWidgetBuilder.text(
                              "Services:",
                              topPadding: 10,
                              bottomPadding: 10
                          ),
                          FutureBuilder(
                            future: _request.getServices(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<CloudNetV3Data> data = snapshot.data as List<CloudNetV3Data>;
                                return ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  primary: false,
                                  padding: EdgeInsets.zero,
                                  itemCount: data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return _serverItem(data[index], orientation);
                                  },
                                );
                              }
                              return MainWidgetBuilder.text("Loading...", leftPadding: paddingDependOnOrientation);
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    return _wrongResponse();
                  }
                }
                if (snapshot.hasError) {
                  if(snapshot.error is InvalidCredential && (_model.username == null || _model.username.isEmpty || _model.password == null || _model.password.isEmpty)) {
                    _showDialog();
                  } else {
                    print("error: ${snapshot.error}");
                    return MainWidgetBuilder.text("Auth Error", leftPadding: paddingDependOnOrientation);
                  }
                }
                return MainWidgetBuilder.text("Loading...", leftPadding: paddingDependOnOrientation);
              },
            );
          },
        ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
      );

  Widget _wrongResponse() {
    return MainWidgetBuilder.text("Wrong server response");
  }

  Widget _serverItem(CloudNetV3Data cloudNetV3Data, Orientation orientation) {
    double paddingDependOnOrientation = _getPaddingDependOnOrientation(orientation);
    return Column(
      children: <Widget>[
        _getServerItemWidgetDependOnPlatform(cloudNetV3Data, orientation),
        Container(
          padding: EdgeInsets.only(
              left: paddingDependOnOrientation,
              right: paddingDependOnOrientation,
              top: 5,
              bottom: 5
          ),
          child: Container(
            color: ColorConstant.mainHover,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _getServerItemWidgetDependOnPlatform(CloudNetV3Data cloudNetV3Data, Orientation orientation) {
    CloudNetV3Service serviceInfo = cloudNetV3Data.service;
    double paddingDependOnOrientation = _getPaddingDependOnOrientation(orientation);
    if(MediaQuery.of(context).size.width >= 1080 || orientation == Orientation.landscape) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MainWidgetBuilder.text(
              "${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId} (${serviceInfo.lifeCycle})",
              leftPadding: paddingDependOnOrientation,
              rightPadding: paddingDependOnOrientation
          ),
          new Row(
            children: _getButtonsForItems(cloudNetV3Data, orientation),
          ),
        ],
      );
    } else {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MainWidgetBuilder.text(
              "${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId} (${serviceInfo.lifeCycle})",
              leftPadding: paddingDependOnOrientation,
              rightPadding: paddingDependOnOrientation
          ),
          new Row(
            children: _getButtonsForItems(cloudNetV3Data, orientation),
          ),
        ],
      );
    }
  }

  _showDialog() async {
    TextEditingController username = TextEditingController();
    TextEditingController pass = TextEditingController();
    await Future.delayed(Duration(microseconds: 1));
    showDialog(
        context: context,
        builder: (context) => MainWidgetBuilder.alertDialog(
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MainWidgetBuilder.textInput('Username', username),
                  MainWidgetBuilder.textInput('Password', pass)
                ],
              ),
            ),
            actions: <Widget>[
              MainWidgetBuilder.flatButton("Cancel", () {
                Navigator.pop(context);
                Navigator.pop(this.context);
              }),
              MainWidgetBuilder.flatButton("Connect", () {
                _model = _model.copyWith(
                    username: username.text,
                    password: pass.text
                );
                _request = CloudNetV3Requests(_model);
                setState(() {
                  _requestData = _dataRequest();
                  Navigator.pop(context);
                });
              })
            ]
        )
    );
  }

  Future<CloudNetV3Status> _dataRequest() {
    return _request.checkIsCredentialExists().then((value) => _request.login()).then((value) => _request.getStatus());
  }

  List<Widget> _getButtonsForItems(CloudNetV3Data cloudNetV3Data, Orientation orientation) {
    double paddingDependOnOrientation = _getPaddingDependOnOrientation(
        orientation);
    List<Widget> data = [];
    CloudNetV3Service serviceInfo = cloudNetV3Data.service;

    if (cloudNetV3Data.ftp != null) {
      data.add(Padding(
          padding: EdgeInsets.only(left: paddingDependOnOrientation, right: 10),
          child: MainWidgetBuilder.button("FTP data", () {
            CloudNetV3FTPData ftpData = cloudNetV3Data.ftp;
            showDialog(
                context: context,
                builder: (context) =>
                    MainWidgetBuilder.alertDialog(
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MainWidgetBuilder.textWithSelectableText(
                                "Server IP: ", ftpData.ip),
                            MainWidgetBuilder.textWithSelectableText(
                                "Port: ", "${ftpData.port}"),
                            MainWidgetBuilder.textWithSelectableText(
                                "Username: ", ftpData.username),
                            MainWidgetBuilder.textWithSelectableText(
                                "Password: ", ftpData.password),
                          ],
                        ),
                        title: "${serviceInfo.serviceId.taskName}-${serviceInfo
                            .serviceId.taskServiceId} FTP data",
                        actions: [
                          MainWidgetBuilder.flatButton("OK", () {
                            Navigator.pop(context);
                            setState(() {});
                          })
                        ]
                    )
            );
          })
      ));
    }

    double paddingForStop = paddingDependOnOrientation;
    if(orientation == Orientation.landscape) {
      if(cloudNetV3Data.ftp == null) {
        paddingForStop = paddingDependOnOrientation;
      } else {
        paddingForStop = 0;
      }
    }

    data.add(Padding(
        padding: EdgeInsets.only(left: paddingForStop, right: 10),
        child: MainWidgetBuilder.button("Stop", () {
          _request.stopService(serviceInfo.serviceId.uniqueId).then((success) {
            String mainText;
            if (success) {
              mainText =
              "Service ${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId
                  .taskServiceId} stopped success";
            } else {
              mainText =
              "An error occurred when try to stop service ${serviceInfo
                  .serviceId.taskName}-${serviceInfo.serviceId.taskServiceId}";
            }
            return showDialog(
                context: context,
                builder: (context) =>
                    MainWidgetBuilder.alertDialog(
                      MainWidgetBuilder.text(mainText),
                      title: "${serviceInfo.serviceId.taskName}-${serviceInfo
                          .serviceId.taskServiceId}",
                      actions: [
                        MainWidgetBuilder.flatButton("OK", () {
                          Navigator.pop(context);
                          setState(() {});
                        })
                      ],
                    )
            );
          });
        })
    ));
    data.add(
        Padding(
            padding: EdgeInsets.only(right: paddingDependOnOrientation),
            child: MainWidgetBuilder.button("Open Console", () {
              Navigator.push(context, new MaterialPageRoute(builder: (ctxt) =>
                  CloudNetV3Terminal(_request, serviceInfo)),);
            })
        )
    );

    return data;
  }

  double _getPaddingDependOnOrientation(Orientation orientation) {
    double paddingDependOnOrientation = DEFAULT_PADDING;
    if(orientation == Orientation.landscape) {
      paddingDependOnOrientation = LANDSCAPE_PADDING;
    }
    return paddingDependOnOrientation;
  }

}
