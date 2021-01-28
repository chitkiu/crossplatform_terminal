import 'package:flutter/material.dart';
import 'color_constants.dart';

import 'presentation/screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Cross-platform terminal',
        theme: ThemeData(
          canvasColor: ColorConstant.mainBackground,
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthScreen()
    );
  }
}
