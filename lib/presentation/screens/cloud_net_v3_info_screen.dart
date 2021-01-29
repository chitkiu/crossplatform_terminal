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
        body: FutureBuilder(
          future: _requestData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is CloudNetV3Status) {
                CloudNetV3Status data = (snapshot.data as CloudNetV3Status);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          MainWidgetBuilder.text("Node name: ", topPadding: 10),
                          MainWidgetBuilder.text(data.info.name, topPadding: 10)
                        ],
                      ),
                      Row(
                        children: [
                          MainWidgetBuilder.text("RAM(reserved/total): ", topPadding: 10),
                          MainWidgetBuilder.text("${data.currentNetworkClusterNodeInfoSnapshot
                              .reservedMemoryInMB}/${data
                              .currentNetworkClusterNodeInfoSnapshot
                              .maxMemoryInMB}", topPadding: 10)
                        ],
                      ),
                      Row(
                        children: [
                          MainWidgetBuilder.text("CPU load: ", topPadding: 10),
                          MainWidgetBuilder.text("${data.currentNetworkClusterNodeInfoSnapshot
                              .systemCpuUsage}", topPadding: 10)
                        ],
                      ),
                      MainWidgetBuilder.text("Services:", topPadding: 10, bottomPadding: 10),
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
                                return _serverItem(data[index]);
                              },
                            );
                          }
                          return MainWidgetBuilder.text("Loading...");
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
                return _cannotAuth();
              }
            }
            return MainWidgetBuilder.text("Loading...");
          },
        ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
      );

  Widget _cannotAuth() {
    return MainWidgetBuilder.text("Auth Error");
  }

  Widget _wrongResponse() {
    return MainWidgetBuilder.text("Wrong server response");
  }

  Widget _serverItem(CloudNetV3Data cloudNetV3Data) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: _getServerItemWidgetDependOnPlatform(cloudNetV3Data),
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
  }

  Widget _getServerItemWidgetDependOnPlatform(CloudNetV3Data cloudNetV3Data) {
    CloudNetV3Service serviceInfo = cloudNetV3Data.service;
    if(MediaQuery.of(context).size.width >= 1080/*kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows*/) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MainWidgetBuilder.text("${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId} (${serviceInfo.lifeCycle})", topPadding: 10, bottomPadding: 10),
          new Row(
            children: _getButtonsForItems(cloudNetV3Data),
          ),
        ],
      );
    } else {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MainWidgetBuilder.text("${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId} (${serviceInfo.lifeCycle})", topPadding: 10, bottomPadding: 10),
          new Row(
            children: _getButtonsForItems(cloudNetV3Data),
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

  List<Widget> _getButtonsForItems(CloudNetV3Data cloudNetV3Data) {
    List<Widget> data = [];
    CloudNetV3Service serviceInfo = cloudNetV3Data.service;

    if (cloudNetV3Data.ftp != null) {
      data.add(Padding(
          padding: EdgeInsets.only(right: 10),
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
                        title: "${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId} FTP data",
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

    data.add(Padding(
        padding: EdgeInsets.only(right: 10),
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
                      title: "${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId}",
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
    data.add(MainWidgetBuilder.button("Open Console", () {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (ctxt) => CloudNetV3Terminal(_request, serviceInfo)),
      );
    }));

    return data;
  }

}
