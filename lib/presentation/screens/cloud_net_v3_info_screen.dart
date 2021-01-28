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
    _requestData = _dataRequest();
  }

  Future<CloudNetV3Status> _requestData;

  CloudNetV3ServerModel _model;
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
          future: _requestData,
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
                          List<CloudNetV3Data> data = snapshot.data as List<CloudNetV3Data>;
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              CloudNetV3Service serviceInfo = data[index].service;
                              return Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        _text("${serviceInfo.serviceId.taskName}-${serviceInfo.serviceId.taskServiceId} (${serviceInfo.lifeCycle})"),
                                        new Row(
                                          children: _getButtonsForItems(data[index]),
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
                        return _text("Loading...");
                      },
                    )
                  ],
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
            return _text("Loading...");
          },
        ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
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

  _showDialog() async {
    TextEditingController username = TextEditingController();
    TextEditingController pass = TextEditingController();
    await Future.delayed(Duration(microseconds: 1));
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: username,
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Username'),
                ),
                TextField(
                  obscureText: true,
                  controller: pass,
                  autofocus: false,
                  decoration: new InputDecoration(
                      labelText: 'Password'),
                )
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(this.context);
                }),
            new FlatButton(
                child: const Text('Connect'),
                onPressed: () {
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
          ],
        )
    );
  }

  Future<CloudNetV3Status> _dataRequest() {
    return _request.checkIsCredentialExists().then((value) => _request.login()).then((value) => _request.getStatus());
  }

  List<Widget> _getButtonsForItems(CloudNetV3Data cloudNetV3Data) {
    List<Widget> data = new List();
    CloudNetV3Service serviceInfo = cloudNetV3Data.service;

    if (cloudNetV3Data.ftp != null) {
      data.add(Padding(
          padding: EdgeInsets.only(right: 10),
          child: _button("FTP data", () {
            CloudNetV3FTPData ftpData = cloudNetV3Data.ftp;
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: new Text(
                        "${serviceInfo.serviceId.taskName}-${serviceInfo
                            .serviceId.taskServiceId}"),
                    content: new SelectableText(
                        "FTP server: ${ftpData.ip}\nFTP port: ${ftpData.port}\nFTP username: ${ftpData.username}\nFTP password: ${ftpData.password}\n"
                    ),
                    actions: [
                      new FlatButton(
                        child: new Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
            );
          })
      ));
    }

    data.add(Padding(
        padding: EdgeInsets.only(right: 10),
        child: _button("Stop", () {
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
                  AlertDialog(
                    title: new Text(
                        "${serviceInfo.serviceId.taskName}-${serviceInfo
                            .serviceId.taskServiceId}"),
                    content: new Text(mainText),
                    actions: [
                      new FlatButton(
                        child: new Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
            );
          });
        })
    ));
    data.add(_button("Open Console", () {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (ctxt) => CloudNetV3Terminal(_request, serviceInfo)),
      );
    }));

    return data;
  }

}
