import 'package:flutter/material.dart';
import 'color_constants.dart';

import 'presentation/screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          canvasColor: ColorConstant.mainBackground,
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainScreen()
    );
  }
}
