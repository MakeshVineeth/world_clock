import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock/commons.dart';
import 'package:flutter_clock/home.dart';
import 'package:flutter_clock/loader.dart';
import 'package:flutter_clock/locations.dart';

void main() {
  runApp(MyClockApp());
  GestureBinding.instance.resamplingEnabled = true;
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
        '/location': (context) => Location(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
