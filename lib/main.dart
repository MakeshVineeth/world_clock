import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/commons.dart';
import 'package:flutter_clock/home.dart';
import 'package:flutter_clock/loader.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(MyClockApp());
}

class MyClockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clock',
      theme: Commons.getColorData(context),
      themeMode: ThemeMode.light,
      routes: {
        '/': (context) => Loader(),
        '/home': (context) => Home(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
