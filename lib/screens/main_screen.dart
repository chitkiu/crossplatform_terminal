import 'package:flutter/material.dart';
import 'package:flutter_app/color_constants.dart';
import 'package:flutter_app/domain/repositories/base_model_repository.dart';
import 'package:flutter_app/domain/repositories/ftp_model_repository.dart';
import 'package:flutter_app/domain/repositories/ssh_model_repository.dart';
import 'package:flutter_app/presentation/click_listener.dart';
import 'package:flutter_app/presentation/list_child_provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<StatefulWidget> {

  ModelRepository _repo;
  ClickListener _clickListener;
  ListChildProvider _listChildProvider;

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  "TERMINAL BLET",
                style: TextStyle(
                  color: ColorConstant.appBarText
                ),
              ),
              backgroundColor: ColorConstant.appBarBackground,
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                        'SSH connection',
                        style: TextStyle(
                            color: ColorConstant.mainText
                        )
                    ),
                    onTap: () {
                      setState(() {
                        _repo = SSHModelRepository();
                        _clickListener = SSHClickListener();
                        _listChildProvider = SSHChildProvider();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    hoverColor: ColorConstant.mainHover,
                    title: Text(
                      'SFTP connection',
                      style: TextStyle(
                          color: ColorConstant.mainText
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _repo = FTPModelRepository();
                        _clickListener = FTPClickListener();
                        _listChildProvider = FTPChildProvider();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            body: ListView.builder(
                itemCount: _repo.getModels().length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return _listChildProvider.provide(_repo[index], ctxt);
                }
            ),
          );
        }
    );
  }

  @override
  void initState() {
    _repo = SSHModelRepository();
    _clickListener = SSHClickListener();
    _listChildProvider = SSHChildProvider();
  }
}
