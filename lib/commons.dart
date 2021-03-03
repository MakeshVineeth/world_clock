import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Commons {
  static final circleRadius = BorderRadius.circular(20);

  static ThemeData getColorData(BuildContext context) {
    Color bgColor = Colors.blue;
    MaterialColor materialColor = Colors.blue;

    return ThemeData(
      primarySwatch: materialColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: bgColor,
        centerTitle: true,
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );
  }
}
