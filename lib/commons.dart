import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'dart:io' show Platform;

class Commons {
  static ThemeData getColorData(BuildContext context) {
    Color bgColor = Colors.blue;
    MaterialColor materialColor = Colors.blue;

    return ThemeData(
      primarySwatch: materialColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: bgColor,
      ),
    );
  }

  static setStatusBarColor({@required BuildContext context}) {
    if (Platform.isAndroid) {
      FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    }
  }
}
