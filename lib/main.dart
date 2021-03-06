import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'color_constants.dart';

import 'presentation/screens/auth_screen.dart';
import 'constants.dart';

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
          appBarTheme: Theme.of(context)
              .appBarTheme
              .copyWith(brightness: Brightness.dark, backgroundColor: Colors.white)
        ),
        home: AuthScreen()
    );
  }
}
